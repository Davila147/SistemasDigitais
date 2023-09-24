library IEEE;
use ieee.numeric_bit.all;

entity multiplicador_tb_vetorteste is
end entity;

architecture tb of multiplicador_tb_vetorteste is

    component multiplicador is
        port (Clock:    in  bit;
        Reset:    in  bit;
        Start:    in  bit;
        Va,Vb:    in  bit_vector(3 downto 0);
        Vresult:  out bit_vector(7 downto 0);
        Ready:    out bit
        );
    end component;

    signal clk_in: bit := '0';
    signal rst_in, start_in, ready_out: bit := '0';
    signal va_in, vb_in: bit_vector(3 downto 0);
    signal result_out: bit_vector(7 downto 0);

    signal keep_simulating: bit := '0';
    constant clockPeriod : time := 1 ns;

    begin
    
        clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
       
        dut: multiplicador
             port map(Clock=>   clk_in,
                      Reset=>   rst_in,
                      Start=>   start_in,
                      Va=>      va_in,
                      Vb=>      vb_in,
                      Vresult=> result_out,
                      Ready=>   ready_out
            );

    gerador_estimulos: process is

        type pattern_type is record
            -- Entradas
            Va_tb: bit_vector(3 downto 0);
            Vb_tb: bit_vector(3 downto 0);
            -- Saídas
            Vresult_tb: bit_vector(7 downto 0);
        end record;

        type pattern_array is array (natural range <>) of pattern_type;

        constant patterns : pattern_array :=

        (
         ("0011", "0110", "00010010"),
         ("1111", "1011", "10100101"),
         ("1111", "0000", "00000000"),
         ("0001", "1011", "00001011")
        );

        begin

            assert false report "simulation start" severity note;
            keep_simulating <= '1';

            rst_in <= '1';
            start_in <= '0';
            wait for clockPeriod;
            rst_in <= '0';

            for i in patterns'range loop
                va_in <= patterns(i).Va_tb;
                vb_in <= patterns(i).Vb_tb;
                wait until falling_edge(clk_in);
                start_in <= '1';
                wait until falling_edge(clk_in);
                start_in <= '0';
                wait until ready_out='1';

                assert (result_out = patterns(i).Vresult_tb)
                        report "Teste " & integer'image(i) & " > "
                        & "Resultado: " & integer'image(to_integer(unsigned(result_out))) & " (obtido), "
                         & integer'image(to_integer(unsigned(patterns(i).Vresult_tb))) & " (esperado); "
                severity error;
                
                wait for clockPeriod;

            end loop;

            assert false report "Simulation end" severity note;
            keep_simulating <= '0';

            wait;
            end process;
            
        end architecture;