library ieee;
use ieee.numeric_bit.all;

entity multiplicador_modificado is
    port (
        Clock: in bit;
        Reset: in bit;
        Start: in bit;
        Va, Vb: in bit_vector(3 downto 0);
        Vresult: out bit_vector(7 downto 0);
        Ready: out bit
    );
end entity;

architecture structural of multiplicador_modificado is
    
    component mm_uc is
        port (
            clock: in bit;
            reset: in bit;
            start: in bit;
            count_finish: in bit;
            int_Vresult: in bit_vector(7 downto 0);
            RST_reg: out bit;
            en_reg_4: out bit;
            en_reg_9: out bit;
            ready: out bit;
            Vresult: out bit_vector(7 downto 0)
        );
    end component;

    component mm_fd is
        port (
            clock: in bit;
            Va: in bit_vector(3 downto 0);
            Vb: in bit_vector(3 downto 0);
            RST_reg: in bit;
            en_reg_4: in bit;
            en_reg_9: in bit;
            count_finish: out bit;
            int_Vresult: out bit_vector(7 downto 0)
        );
    end component;

    signal s_clock_n: bit;
    signal s_RST_reg: bit;
    signal s_en_reg_4: bit;
    signal s_en_reg_9: bit;
    signal s_count_finish: bit;
    signal s_Vresult: bit_vector(7 downto 0);

begin

    s_clock_n <= not Clock;

    UC: mm_uc port map (
        clock => Clock,
        reset => Reset,
        start => Start,
        count_finish => s_count_finish,
        int_Vresult => s_Vresult,
        RST_reg => s_RST_reg,
        en_reg_4 => s_en_reg_4,
        en_reg_9 => s_en_reg_9,
        ready => Ready,
        Vresult => Vresult
    );

    FD: mm_fd port map (
        clock => s_clock_n,
        Va => Va,
        Vb => Vb,
        RST_reg => s_RST_reg,
        en_reg_4 => s_en_reg_4,
        en_reg_9 => s_en_reg_9,
        count_finish => s_count_finish,
        int_Vresult => s_Vresult
    );

end architecture;

----------------------------------------------------------------

library IEEE;
use ieee.numeric_bit.all;

entity mm_uc is
    port (
        clock: in bit;
        reset: in bit;
        start: in bit;
        count_finish: in bit;
        int_Vresult: in bit_vector(7 downto 0);
        RST_reg: out bit;
        en_reg_4: out bit;
        en_reg_9: out bit;
        ready: out bit;
        Vresult: out bit_vector(7 downto 0)
    );
end entity;

architecture fsm of mm_uc is
  type state_t is (idle, play, processo, fim);
  signal next_state, current_state: state_t;
    begin
    fsm: process(clock, reset, start)
    begin
        if(rising_edge(clock)) then
            if(reset = '1') then
                current_state <= idle;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    next_state <=
        --idle when (reset = '1') or (start = '0') else
        --processo when (start = '1' and reset = '0') or (current_state = processo and count_finish = '0') else
        --fim when (count_finish = '1') or (current_state = fim and reset = '0') else
        --idle;

        idle when (current_state = idle) and (reset = '1') and (start = '0') else 
        play when (current_state = idle) and (start = '1') else 

        fim when (current_state = processo) and (count_finish = '1') else 
        processo when (current_state = processo) and (count_finish = '0') else 

        fim when (current_state = fim) and (reset = '0');

    RST_reg <= '1' when current_state = idle else '0';
    en_reg_4 <= '1' when current_state = processo else '0';
    en_reg_9 <= '1' when current_state = processo else '0';
    ready <= '1' when current_state = fim else '0';

    Vresult <= int_Vresult when (current_state = fim);

end architecture;

---------------------------------------------------------------------------------

library IEEE;
use ieee.numeric_bit.all;

entity mm_fd is
    port (
        clock: in bit;
        Va: in bit_vector(3 downto 0);
        Vb: in bit_vector(3 downto 0);
        RST_reg: in bit;
        en_reg_4: in bit;
        en_reg_9: in bit;
        count_finish: out bit;
        int_Vresult: out bit_vector(7 downto 0)
    );
end entity;

architecture structural of mm_fd is

    component reg_desloc_4 is
        port (
            clock: in bit;
            enable: in bit;
            reset: in bit;
            dado: in bit_vector(3 downto 0); -- recebe Va
            desloc_finish: out bit; -- '1' quando acaba tudo
            bit_out : out bit -- bit menos significativo saindo
        );
    end component;

    component reg_desloc_9 is
        port (
            clock: in bit;
            enable: in bit;
            reset: in bit;
            carry_in: in bit;
            entrada: in bit_vector(3 downto 0); -- entrada vinda do adder
            saida: out bit_vector(8 downto 0)
        );
    end component;

    component adder is
        port (
            enable: in bit;
            A: in bit_vector(3 downto 0);
            B: in bit_vector(3 downto 0);
            carry_out: out bit;
            sum: out bit_vector(3 downto 0)
        );
    end component;

    signal s_enable_adder: bit;
    signal s_carry: bit;
    signal s_entrada: bit_vector(3 downto 0);
    signal s_saida_somar: bit_vector(3 downto 0);
    signal s_saida_Vresult: bit_vector(8 downto 0);

begin

    s_saida_somar <= s_saida_Vresult(7 downto 4);
    int_Vresult <= "00000000" when (Va = "00000000") or (Vb = "00000000") or (RST_reg = '1') else 
                  s_saida_vResult(7 downto 0);

    DESLOCADOR_4: reg_desloc_4 port map (
        clock => clock,
        enable => en_reg_4,
        reset => RST_reg,
        dado => Va,
        desloc_finish => count_finish,
        bit_out => s_enable_adder
    );

    SOMADOR: adder port map (
        enable => s_enable_adder,
        A => s_saida_somar,
        B => Vb,
        carry_out => s_carry,
        sum => s_entrada
    );

    DESLOCADOR_9: reg_desloc_9 port map (
        clock => clock,
        enable => en_reg_9,
        reset => RST_reg,
        carry_in => s_carry,
        entrada => s_entrada,
        saida => s_saida_Vresult
    );

end architecture;

--------------------------------------------------------------------------------------

library IEEE;
use ieee.numeric_bit.all;

entity reg_desloc_4 is
    port (
        clock: in bit;
        enable: in bit;
        reset: in bit;
        dado: in bit_vector(3 downto 0); -- recebe Va
        desloc_finish: out bit; -- '1' quando acaba tudo
        bit_out : out bit -- bit menos significativo saindo
    );
end entity;

architecture arch_reg_desloc_4 of reg_desloc_4 is
    signal s_dado: bit_vector(3 downto 0);
    signal internal_count: unsigned(2 downto 0);

begin

    process(clock, reset)
    begin
        if reset = '1' then
            s_dado <= dado;
            internal_count <= (others => '0');
        elsif (rising_edge(clock)) then
            if (enable='1') then
                bit_out <= s_dado(0);
                s_dado <= ('0' & s_dado(3 downto 1));
                internal_count <= internal_count + 1;
            end if;
        end if;
    end process;

    desloc_finish <= '1' when (internal_count = 4) or (dado = "0000") else '0';
             
end architecture;

------------------------------------------------------------------------

library IEEE;
use ieee.numeric_bit.all;

entity reg_desloc_9 is
    port (
        clock: in bit;
        enable: in bit;
        reset: in bit;
        carry_in: in bit;
        entrada: in bit_vector(3 downto 0); -- entrada vinda do adder
        saida: out bit_vector(8 downto 0)
    );
end entity;

architecture arch_reg_desloc_9 of reg_desloc_9 is
    signal s_dado: bit_vector(8 downto 0);

begin

    process(clock, reset)
    begin
        if reset = '1' then
          	s_dado <= (others => '0');       
        elsif (rising_edge(clock)) then
            if (enable = '1') then
                if (entrada = "0000") then
                    s_dado <= ('0' & s_dado(8 downto 1));
                else
                    s_dado(8) <= carry_in;
                    s_dado(7 downto 4) <= entrada;
                    s_dado <=('0' & s_dado(8 downto 1));
                end if;
            end if;
        end if;
    end process;

    saida <= s_dado;          

end architecture;

------------------------------------------------------------------

library IEEE;
use ieee.numeric_bit.all;

entity adder is
    port (
        enable: in bit;
        A: in bit_vector(3 downto 0);
        B: in bit_vector(3 downto 0);
        carry_out: out bit;
        sum: out bit_vector(3 downto 0)
    );
end entity;

architecture arch_adder of adder is
    signal temp_sum: unsigned(4 downto 0);
    signal temp_cout: bit;
begin
    process (A, B, enable)
    begin
        if enable = '1' then
          temp_sum <= unsigned(A) + unsigned(B);
            temp_cout <= temp_sum(4);
        else
            temp_sum <= "00000";
            temp_cout <= '0';
        end if;
    end process;

          sum <= bit_vector(temp_sum(3 downto 0));
    carry_out <= temp_cout;
end architecture;