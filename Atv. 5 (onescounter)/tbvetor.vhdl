library IEEE;
use ieee.numeric_bit.all;

entity tbvetor is
end entity;

architecture tb of tbvetor is

    component onescounter is
        port (Clock:    in  bit;
        Reset:    in  bit;
        Start:    in  bit;
        Inport:    in  bit_vector(14 downto 0);
        Outport:  out bit_vector(3 downto 0);
        Done:    out bit
        );
    end component;

    signal clk_in: bit := '0';
    signal rst_in, start_in, done_out: bit := '0';
    signal inport_in: bit_vector(14 downto 0);
    signal outport_out: bit_vector(3 downto 0);

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
        dut: onescounter
             port map(Clock=>   clk_in,
                      Reset=>   rst_in,
                      Start=>   start_in,
                      Inport=>  inport_in,
                      Outport=> outport_out,
                      Done=>    done_out
            );

    gerador_estimulos: process is

        type pattern_type is record
            -- Entradas
            Inport_tb: bit_vector(14 downto 0);
            -- Saídas
            Outport_tb: bit_vector(3 downto 0);
        end record;

        type pattern_array is array (natural range <>) of pattern_type;

        constant patterns: pattern_array :=

        (("000000000000000", "0000"),
        ("111111111111111", "1111"),
        ("101010101010101", "1000"),
        ("010101010101010", "0111"),
        ("000000000000001", "0001"),
        ("100000000000000", "0001"),
        ("000000010000000", "0001")
        );

        begin

            assert false report "simulation start" severity note;
            keep_simulating <= '1';

            rst_in <= '1';
            start_in <= '0';
            wait for clockPeriod;
            rst_in <= '0';
            
            for i in patterns'range loop
                inport_in <= patterns(i).Inport_tb;
                wait until falling_edge(clk_in);
                start_in <= '1';
                wait until falling_edge(clk_in);
                start_in <= '0';
                wait until done_out = '1';

            assert (outport_out = patterns(i).Outport_tb)
                   report "Teste " & integer'image(i) & " > "
                    & "Resultado: " & integer'image(to_integer(unsigned(Outport_out))) & " (obtido), "
                    & integer'image(to_integer(unsigned(patterns(i).Outport_tb))) & " (esperado); "    
            severity error;

            wait for clockPeriod;
            
            rst_in <= '0';
            
            end loop;

            assert false report "Simulation end" severity note;
            keep_simulating <= '0';

            wait; -- end of simulation
            end process;
            
            end architecture;               