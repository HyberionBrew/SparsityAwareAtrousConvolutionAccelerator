library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
use work.pe_group_pck.all;
use work.test_utils.all;
use std.textio.all;


entity PE_group_tb is
end entity;

architecture arch of PE_group_tb is
    constant CLK_PERIOD : time := 20 ns;
  signal clk: std_logic;
  --index select
      signal request_bus: std_logic;
      signal new_ifmaps,new_kernels: std_logic_vector(PES_PER_GROUP-1 downto 0);
      signal bus_to_mem,debug : std_logic_vector(BUSSIZE-1 downto 0);
      signal reset, out_enable, out_enable_reg, out_enable_reg_nxt,free:std_logic;

      signal finished : std_logic;
      type mem_image_type is array(integer range 0 to 5,integer range 0 to 5,integer range 0 to 34) of integer;
            type mem_image_should_type is array(integer range 0 to 1,integer range 0 to 5,integer range 0 to 5,integer range 0 to 34) of integer;
      signal mem_image_should: mem_image_should_type := (others => (others => (others => (others => 2))));
      signal mem_image: mem_image_type;
      type bus_decoded_type is array(integer range 0 to 17) of integer;
      signal bus_decoded: bus_decoded_type;
      signal current_should: integer := 0;
begin


PE_group_i : entity work.PE_group
  port map (
    reset       => reset,
    clk         => clk,
    finished_out    => finished,
    new_kernels => new_kernels,
    new_ifmaps  => new_ifmaps,
    bus_to_mem   => bus_to_mem,
    request_bus => request_bus,
      out_enable   => out_enable,
      free  => free
  );

  clock : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  check_out:process
  variable should_prev: integer := 0;
  variable out_enable_prev: std_logic;
  variable report_counter :integer :=0;
  begin
    out_enable_prev := '0';
    while true loop
        if out_enable = '0' and out_enable_prev = '1' then
             wait for CLK_PERIOD*5;
             report_counter :=0;
            for kernel in 0 to 5 loop
                for x in 0 to 5 loop
                    for y in 0 to 32 loop


                        if not(mem_image_should(should_prev,kernel,x,y) = mem_image(kernel,x,y)) then
                            report "ERROR " & integer'image(should_prev) & "kernel: " & integer'image(kernel) &" x: "& integer'image(x) & " y: "& integer'image(y);
                            report "SHOULD;" & integer'image(mem_image_should(should_prev,kernel,x,y)) & " is: " & integer'image(mem_image(kernel,x,y));
                            report_counter := report_counter +1;
                        end if;

                    end loop;
                 end loop;
              end loop;
             report "NUMBER OF ERRORS: " & integer'image(report_counter);
             if should_prev= 1 then
                should_prev := 0;
             else
                  should_prev := 1;
             end if;
          end if;

          out_enable_prev := out_enable;
          wait for CLK_PERIOD/2;
        end loop;

  end process;


  stim: process
    file infile : text open read_mode is "../scripts/input_pe_group_test.txt";
    variable inline, outline : line;
    variable int:integer;
    variable in_vec : string(1 to 557);
  begin
    reset <= '0';
    --out_enable <= '0';
    new_kernels <= (others => '0');
    new_ifmaps <= (others => '0');
    bus_to_mem <= (others => 'Z');
    wait for CLK_PERIOD*100;
    reset <= '1';
    while not endfile(infile) loop
        wait for CLK_PERIOD *20; --for free to be low again
        if free= '1' and finished = '1' then
            readline(infile,inline);
            read(inline,int);

            if int = 1 then
            --write the new ifmaps first
                for I in 0 to PES_PER_GROUP-1 loop
                    readline(infile,inline);
                    read(inline, in_vec);
                    bus_to_mem(BUSSIZE-1 downto 0) <= to_std_logic_vector(in_vec);
                    new_ifmaps(I) <= '1';
                    wait for CLK_PERIOD;
                    new_ifmaps(I) <= '0';
                end loop;
             end if;
            --bus_to_pe <= (others => '1');
            --new_ifmaps(0) <= '1';
            new_ifmaps <= (others => '0');
        wait for CLK_PERIOD;
        --write kernel
        readline(infile,inline);
        read(inline, in_vec);
        bus_to_mem(BUSSIZE-1 downto 0) <= to_std_logic_vector(in_vec);
        new_ifmaps <= (others => '0');
        new_kernels <= (others => '1');
        wait for CLK_PERIOD;
        new_kernels <= (others => '0');
        bus_to_mem <= (others => 'Z');
        --now read in should be values
        readline(infile,inline);

        for kernel in 0 to 5 loop
            for x in 0 to 5 loop
                for y in 0 to 32 loop
                    read(inline, int);
                    mem_image_should(current_should,kernel,x,y) <= int;
                end loop;
                readline(infile,inline);
             end loop;
             current_should <= 1;
             if current_should = 1 then
                current_should <= 0;
             end if;
        end loop;

        --for I in 0 to 3 loop
         --   wait for CLK_PERIOD *5; --really important because free reacts with an delay
          --  while true loop
           --     if free = '1' and finished= '1' then
            --        bus_to_mem(BUSSIZE-1 downto 0) <= to_std_logic_vector(in_vec);
             --       new_kernels <= (others => '1');
          --          exit;
          --      end if;
           --     wait for CLK_PERIOD;
     --       end loop;
      --      wait for CLK_PERIOD;
       --     new_kernels <= (others => '0');
        --        bus_to_mem <= (others => 'Z');
  --      end loop;
   --     new_kernels <= (others => '0');
    --    bus_to_mem <= (others => 'Z');
        end if;
        wait for CLK_PERIOD;
    end loop;
    wait;


    --first get N ifmaps (for each PE)
    --then get 1 kernel write it to all PEs
  end process;


  bus_decode: process

  begin
      for I in 1 to 17 loop
        bus_decoded(I-1)<= to_integer(signed(bus_to_mem(24*I-1 downto 24*(I-1))));
    end loop;
    wait for CLK_PERIOD/2;
  end process;

  create_mem_image: process
  variable curr_y, curr_x,kernel : integer;
  begin
    curr_y := 0;
    curr_x := 0;
    kernel := 0;
    mem_image <= (others => (others => (others => 0)));
    wait for CLK_PERIOD/2;
    while true loop
        if out_enable = '1' then
           -- wait for CLK_PERIOD;
            for I in 1 to 17 loop
                mem_image(kernel,curr_x,curr_y+I-1)<= to_integer(signed(bus_to_mem(24*I-1 downto 24*(I-1))));
            end loop;
            curr_x := curr_x +1;
            if curr_x = 6 then
                curr_x := 0;
                kernel := kernel +1;
            end if;

            if kernel = 6 then
                if curr_y = 17 then
                    curr_y := 0;
                    kernel := 0;
                    wait for CLK_PERIOD;
                else
                    kernel := 0;
                    curr_y := 17;
                end if;

            end if;
        end if;
    wait for CLK_PERIOD;
    end loop;
    wait for CLK_PERIOD;
  end process;


  test_out: process
  variable tag : integer:= 0;
  begin
  out_enable <= '0';

  while true loop
          tag := 0;
       wait for CLK_PERIOD;
       out_enable <= '0';
        wait for CLK_PERIOD*3;
        if request_bus = '1' then
        wait for CLK_PERIOD * 100;
        while request_bus = '1' loop
            out_enable <= '1';
            tag := tag + 1;
            if tag = 73 then

                exit;
            end if;
          wait for CLK_PERIOD;
         end loop;
        end if;
      wait for CLK_PERIOD;
  end loop;
  end process;


end architecture;
