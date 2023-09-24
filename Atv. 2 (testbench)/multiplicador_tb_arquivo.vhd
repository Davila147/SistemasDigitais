use std.textio.all;
library IEEE;
use ieee.numeric_bit.all;

entity multiplicador_tb_arquivo is
end entity;

architecture tb of multiplicador_tb_arquivo is

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

    signal keep_simulating: bit := '0'; -- delimita o tempo de geração do clock
    constant clockPeriod : time := 1 ns;

    begin
        -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
        -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
        -- simulação de eventos
        clk_in <= (not clk_in) and keep_simulating after clockPeriod/2;
        
        ---- O código abaixo, sem o "keep_simulating", faria com que o clock executasse
        ---- indefinidamente, de modo que a simulação teria que ser interrompida manualmente
        -- clk_in <= (not clk_in) after clockPeriod/2; 
        
        -- Conecta DUT (Device Under Test)
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
    file tb_file : text open read_mode is "multiplicador4bits_tb_arquivo.dat";
    variable tb_line: line;
    variable space: character;
    variable Va, Vb : bit_vector(3 downto 0);
    variable Vresult : bit_vector(7 downto 0);

    begin

        assert false report "Teste iniciado" severity note;
        keep_simulating <= '1';

        rst_in <= '1';
        start_in <= '0';
        wait for clockPeriod;
        rst_in <= '0';

        while not endfile(tb_file) loop
            readline(tb_file, tb_line);
            read(tb_line, Va);
            read(tb_line, space);
            read(tb_line, Vb);
            read(tb_line, space);
            read(tb_line, Vresult);
            
            Va_in <= Va;
            Vb_in <= Vb;

            wait until falling_edge(clk_in);
            start_in <= '1';
            wait until falling_edge(clk_in);
            start_in <= '0';
            wait until ready_out='1';

            assert result_out = Vresult report "Erro na multiplicação " &
            integer'image(to_integer(unsigned(va))) & " * " &
            integer'image(to_integer(unsigned(vb))) & " não é igual a "
            &  integer'image(to_integer(unsigned(result_out)))
            severity error;

            wait for ClockPeriod;

        end loop;

        assert false report "Teste concluído." severity note;
        wait for clockPeriod;
        keep_simulating <= '0';
        wait;
        end process;
    end architecture;