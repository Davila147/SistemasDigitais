library IEEE;
use ieee.numeric_bit.all;

entity testbench is
end testbench;

architecture tb of testbench is
    component multiplicador_modificado is
    port(
        Clock: in bit;
        Reset: in bit;
        Start: in bit;
        Va, Vb : in bit_vector (3 downto 0);
        Vresult: out bit_vector (7 downto 0);
        Ready: out bit
    );

end component;

-- test signals
signal Va_in, Vb_in: bit_vector(3 downto 0);
signal Clock_in, Reset_in, Start_in: bit;
signal Vresult_out: bit_vector(7 downto 0);
signal Ready_out: bit;

begin
    DUT: multiplicador_modificado port map (
        Clock_in,
        Reset_in,
        Start_in,
        Va_in, Vb_in,
        Vresult_out,
        Ready_out
    );

    process
    begin
    	-- 0000 X 0000
        Clock_in <= '1';
        Reset_in <= '0';
        Start_in <= '1';
        Va_in <= "0000";
        Vb_in <= "0000";    

        wait for 1 ns;
        assert(Vresult_out = "00000000" and Ready_out = '1') report "[!] Failed 1/8" severity error;

        -- 1111 X 1111
        Clock_in <= '1';
        Reset_in <= '0';
        Start_in <= '1';
        Va_in <= "1111";
        Vb_in <= "1111";    

        wait for 1 ns;
        assert(Vresult_out = "11100001" and Ready_out = '1') report "[!] Failed 2/8" severity error;

        -- 0000 X 1111
        Clock_in <= '1';
        Reset_in <= '0';
        Start_in <= '1';
        Va_in <= "1111";
        Vb_in <= "0000";    

        wait for 1 ns;
        assert(Vresult_out = "00000000" and Ready_out = '1') report "[!] Failed 3/8" severity error;

         -- 0101 X 1010
         Clock_in <= '1';
         Reset_in <= '0';
         Start_in <= '1';
         Va_in <= "1010";
         Vb_in <= "0101";    
 
         wait for 1 ns;
         assert(Vresult_out = "00110010" and Ready_out = '1') report "[!] Failed 4/8" severity error;

          -- 0101 X 1111
          Clock_in <= '1';
          Reset_in <= '0';
          Start_in <= '1';
          Va_in <= "1111";
          Vb_in <= "0101";    
  
          wait for 1 ns;
          assert(Vresult_out = "01001011" and Ready_out = '1') report "[!] Failed 5/8" severity error;

          -- 0101 X 1111
          Clock_in <= '1';
          Reset_in <= '0';
          Start_in <= '1';
          Va_in <= "0000";
          Vb_in <= "0101";    
  
          wait for 1 ns;
          assert(Vresult_out = "00000000" and Ready_out = '1') report "[!] Failed 6/8" severity error;

          -- jogo não começou
          Clock_in <= '1';
          Reset_in <= '0';
          Start_in <= '0';
          Va_in <= "1111";
          Vb_in <= "0101";    
  
          wait for 1 ns;
          assert(Vresult_out = "00000000" and Ready_out = '0') report "[!] Failed 7/8" severity error;

          -- jogo não começou
          Clock_in <= '1';
          Reset_in <= '1';
          Start_in <= '1';
          Va_in <= "1111";
          Vb_in <= "0101";    
  
          wait for 1 ns;
          assert(Vresult_out = "00000000" and Ready_out = '1') report "[!] Failed 8/8" severity error;
          
          assert false report "[*] Test done." severity note;
        wait;
    end process;
end tb;