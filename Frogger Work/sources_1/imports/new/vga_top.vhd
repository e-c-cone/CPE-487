-- vga_top.vhd

LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY vga_top IS

	PORT (

		clk_50MHz : IN STD_LOGIC;

		vga_red : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);

		vga_green : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);

		vga_blue : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

		vga_hsync : OUT STD_LOGIC;

		vga_vsync : OUT STD_LOGIC;
		
		-- to allow the snake to move we make l, r, u, d, and reset buttons which will be clicked on the board
		
		b_left : IN STD_LOGIC;
		
		b_right : IN STD_LOGIC;
		
		b_up : IN STD_LOGIC;
		
		b_down : IN STD_LOGIC;
		
		b_reset : IN STD_LOGIC;
		
		anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)

	);

END vga_top;



ARCHITECTURE Behavioral OF vga_top IS

	SIGNAL ck_25 : STD_LOGIC;
	
	SIGNAL cnt : std_logic_vector(20 DOWNTO 0);

	SIGNAL S_red, S_green, S_blue : STD_LOGIC;

	SIGNAL S_vsync : STD_LOGIC;

	SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
	
	SIGNAL S_data : STD_LOGIC_VECTOR (15 DOWNTO 0);
	
	SIGNAL led_mpx : STD_LOGIC_VECTOR (1 DOWNTO 0); -- 7-seg multiplexing clock

	COMPONENT froggie IS

		PORT (

			v_sync : IN STD_LOGIC;

			pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);

			pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);

			red : OUT STD_LOGIC;

			green : OUT STD_LOGIC;

			blue : OUT STD_LOGIC;
			
			-- the movements
			
			left: IN STD_LOGIC;

            right: IN STD_LOGIC;
            
            up: IN STD_LOGIC;
            
            down: IN STD_LOGIC;
                        
            reset: IN STD_LOGIC;

			score: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);

	END COMPONENT;

	COMPONENT vga_sync IS

		PORT (

			pixel_clk : IN STD_LOGIC;

			red_in : IN STD_LOGIC;

			green_in : IN STD_LOGIC;

			blue_in : IN STD_LOGIC;

			red_out : OUT STD_LOGIC;

			green_out : OUT STD_LOGIC;

			blue_out : OUT STD_LOGIC;

			hsync : OUT STD_LOGIC;

			vsync : OUT STD_LOGIC;

			pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);

			pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)

		);

	END COMPONENT;
	
	COMPONENT leddec IS

        PORT (

            dig : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

            f_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

            anode : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)

        );

    END COMPONENT;

BEGIN

	-- Process to generate 25 MHz clock from 50 MHz system clock
ckp : PROCESS (clk_50MHz)
	BEGIN	
		IF rising_edge(clk_50MHz) THEN		
			cnt <= cnt + 1;
			ck_25 <= NOT ck_25;
		END IF;
	END PROCESS;


	led_mpx <= cnt(18 downto 17);

	-- vga_driver only drives MSB of red, green & blue

	-- so set other bits to zero

	vga_red(1 DOWNTO 0) <= "00";

	vga_green(1 DOWNTO 0) <= "00";

	vga_blue(0) <= '0';

	add_frog : froggie

	PORT MAP( --instantiate frog component

		v_sync => S_vsync, 

		pixel_row => S_pixel_row, 

		pixel_col => S_pixel_col, 

		red => S_red, 

		green => S_green, 

		blue => S_blue,
		
		--movements
		
		up => b_up,
		
		down => b_down,
		
		left => b_left,
		
		right => b_right,
		
		reset => b_reset,
		
		score => S_data
		
	);

	vga_driver : vga_sync

	PORT MAP(--instantiate vga_sync component

		pixel_clk => ck_25, 

		red_in => S_red, 

		green_in => S_green, 

		blue_in => S_blue, 

		red_out => vga_red(2), 

		green_out => vga_green(2), 

		blue_out => vga_blue(1), 

		pixel_row => S_pixel_row, 

		pixel_col => S_pixel_col, 

		hsync => vga_hsync, 

		vsync => S_vsync

	);

	vga_vsync <= S_vsync; --connect output vsync
	
	led_driver : leddec
	
	PORT MAP(
		
		dig => led_mpx,
	
		f_data => S_data,
	
		anode => anode,
	
		seg => seg
	
	);
	

END Behavioral;

