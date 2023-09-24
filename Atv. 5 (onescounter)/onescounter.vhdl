library ieee;
use ieee.numeric_bit.all;

entity onescounter is
    port (
        clock: in bit;
        reset: in bit;
        start: in bit;
        inport: in bit_vector(14 downto 0);
        outport: out bit_vector(3 downto 0);
        done: out bit
    );
end entity;

architecture structural of onescounter is

    component UC_onescounter is
        port (
            clock: in bit;
            reset: in bit;
            start: in bit;
            
            Verif_one: in bit;
            Verif_end: in bit;
            RST_desloc: out bit;
            RST_cont: out bit;
            EN_desloc: out bit;
            EN_cont: out bit;
            load_desloc: out bit;

            done: out bit
        );
    end component;

    component FD_onescounter is
        port (
            clock: in bit;
            inport: in bit_vector(14 downto 0);

            RST_desloc: in bit;
            RST_cont: in bit;
            EN_desloc: in bit;
            EN_cont: in bit;
            load_desloc: in bit;
            Verif_one : out bit;
            Verif_end: out bit;

            outport: out bit_vector(3 downto 0)
        );
    end component;

    signal s_clock_n: bit;
    signal s_rst_desloc, s_rst_cont: bit;
    signal s_en_desloc, s_en_cont: bit;
    signal s_verif_one, s_verif_end: bit;
    signal s_load_desloc: bit;

begin

    s_clock_n <= not Clock;

    UC: UC_onescounter port map (
        clock => clock,
        reset => reset,
        start => start,
            
        Verif_one => s_verif_one,
        Verif_end => s_verif_end,
        RST_desloc => s_rst_desloc,
        RST_cont => s_rst_cont,
        EN_desloc => s_en_desloc,
        EN_cont => s_en_cont,
        load_desloc => s_load_desloc,

        done => done
    );

    FD: FD_onescounter port map (
        clock => s_clock_n,
        inport => inport,

        RST_desloc => s_rst_desloc,
        RST_cont =>  s_rst_cont,
        EN_desloc => s_en_desloc,
        EN_cont => s_en_cont,
        load_desloc => s_load_desloc,
        Verif_one => s_verif_one,
        Verif_end => s_verif_end,

        outport => outport
    );

end architecture;

-----------UC------------
library ieee;
use ieee.numeric_bit.all;

entity UC_onescounter is
    port (
        clock: in bit;
        reset: in bit;
        start: in bit;

        RST_desloc: out bit;
        RST_cont: out bit;
        EN_desloc: out bit;
        EN_cont: out bit;
        load_desloc: out bit;
        Verif_one : in bit;
        Verif_end: in bit;

        done: out bit
    );
end entity;

architecture arch_UC_onescounter of UC_onescounter is
    type state_t is (idle_s, start_s, desloca_s, soma_s, fim_s);
    signal current_state, next_state: state_t;
  
    begin
      mef: process(clock, reset)
      begin
          if(rising_edge(clock)) then
              if(reset = '1') then
                  current_state <= idle_s;
              else
                  current_state <= next_state;
              end if;
          end if;
      end process;  

    -- Logica de proximo estado
    next_state <=
      --idle
      start_s when (current_state = idle_s) and (start = '1') else  
      idle_s when (current_state = idle_s) and (reset = '1') and (start = '0') else
      --start
      desloca_s when (current_state = start_s) and (verif_end = '0') else
      fim_s when (current_state = start_s) and (verif_end = '1') else
      --desloca
      desloca_s when (current_state = desloca_s) and (verif_one = '0') else
      soma_s when (current_state = desloca_s) and (verif_one = '1') else
      --soma
      desloca_s when (current_state = soma_s) and (verif_end = '0') else
      fim_s when (current_state = soma_s) and (verif_end = '1') else
      --fim
      idle_s when (current_state = fim_s); --and (reset = '1');

    -- Decodifica o estado para gerar sinais de controle
    done <= '1' when current_state = fim_s else '0';
    en_desloc <= '1' when current_state = desloca_s else '0';
    en_cont <= '1' when current_state = soma_s else '0';
    RST_desloc <= '1' when current_state = idle_s else '0';
    RST_cont <= '1' when current_state = idle_s else '0';
    load_desloc <= '1' when current_state = start_s else '0';

end architecture; 


------------------FD------------
library ieee;
use ieee.numeric_bit.all;

entity FD_onescounter is
    port (
        clock: in bit;
        inport: in bit_vector(14 downto 0);

        RST_desloc: in bit;
        RST_cont: in bit;
        EN_desloc: in bit;
        EN_cont: in bit;
        load_desloc: in bit;
        Verif_one : out bit;
        Verif_end: out bit;

        outport: out bit_vector(3 downto 0)
    );
end entity;

architecture arch_FD of FD_onescounter is

    component Reg_Desloc is
        port ( 
            clock : in bit;
            reset : in bit;
            enable : in bit;
            load : in bit;
            parallel_in : in bit_vector(14 downto 0);
            parallel_out : out bit_vector(14 downto 0);
            serial_out : out bit
        );
    end component;

    component counter is
        port (
        clock   : in bit;                     -- Sinal de clock
        reset   : in bit;                     -- Sinal de reset
        enable  : in bit;
        count   : out bit_vector(3 downto 0)
    );
    end component;

    --SINAIS INTERNOS--
    signal s_parallel_out: bit_vector(14 downto 0);
    signal s_serial_out: bit;
        
    begin
        
        verif_end <= '1' when (inport = "000000000000000") else
                     not(s_parallel_out(14) or s_parallel_out(13) or s_parallel_out(12) or s_parallel_out(11) or s_parallel_out(10) or s_parallel_out(9) or s_parallel_out(8) or s_parallel_out(7) or s_parallel_out(6) or s_parallel_out(5) or s_parallel_out(4) or s_parallel_out(3)or s_parallel_out(2) or s_parallel_out(1) or s_parallel_out(0));

        DESLOCADOR: Reg_Desloc port map (
            clock,
            RST_desloc,                
            EN_desloc,
            load_desloc,
            inport,
            s_parallel_out,
            s_serial_out
        );
        
        Verif_one <= s_serial_out;
        
        CONTADOR: counter port map (
            clock,
            RST_cont,
            EN_cont,
            outport
        );
        
end architecture;

---------------------REGISTRADOR DESLOCADOR---------------------------
library ieee;
use ieee.numeric_bit.all;

entity Reg_Desloc is
    port ( 
        clock : in bit;
        reset : in bit;
        enable : in bit;
        load : in bit;
        parallel_in : in bit_vector(14 downto 0);
        parallel_out : out bit_vector(14 downto 0);
        serial_out : out bit
    );
end entity;

architecture arch_desloc of Reg_Desloc is
    signal register_data : bit_vector(14 downto 0);
    signal serial_data : bit;
begin
    process(clock, reset)
    begin
        if reset = '1' then
            register_data <= (others => '0');
            serial_data <= '0';
        elsif (rising_edge(clock)) then
            if load = '1' then
                register_data <= parallel_in;
                serial_data <= '0';
            elsif enable = '1' then
                serial_data <= register_data(0);
                register_data <= '0' & register_data(14 downto 1);
            end if;
        end if;
    end process;

    parallel_out <= register_data;
    serial_out <= serial_data;
end architecture;

------------------------------------------------- CONTADOR -----------------------------------------
library ieee;
use ieee.numeric_bit.all;

entity counter is
    port (
        clock   : in bit;                     -- Sinal de clock
        reset   : in bit;                     -- Sinal de reset
        enable  : in bit;
        count   : out bit_vector(3 downto 0)
    );
end entity;
  
architecture arch_counter of counter is
    signal s_counter : unsigned(3 downto 0);  -- Sinal interno para o contador
  begin
    process(clock, reset)
    begin
        if reset = '1' then
            s_counter <= (others => '0');  -- Reinicia o contador para 0 quando o sinal de reset está ativo
        elsif (rising_edge(Clock) and enable = '1') then
            s_counter <= s_counter + 1;    -- Incrementa o contador
        end if;
    end process;
  
    count <= bit_vector(s_counter);  -- Converte o sinal unsigned para std_logic_vector
end architecture;

