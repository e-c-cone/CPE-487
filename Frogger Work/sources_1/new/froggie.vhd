LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY froggie IS
	PORT (
		v_sync    : IN STD_LOGIC;
		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
		red       : OUT STD_LOGIC;
		green     : OUT STD_LOGIC;
		blue      : OUT STD_LOGIC;
		up        : IN STD_LOGIC;
		down      : IN STD_LOGIC;
	    left      : IN STD_LOGIC;
	    right     : IN STD_LOGIC;
	    reset     : IN STD_LOGIC;
		score 	  : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END froggie;

ARCHITECTURE Behavioral OF froggie IS
 -- signals and variables for frog
	CONSTANT size  : INTEGER := 8;
	SIGNAL frog_on : STD_LOGIC; -- indicates whether frog is over current pixel position
	SIGNAL frog_dead : STD_LOGIC := '0';
	SIGNAL win : STD_LOGIC := '0';
	SIGNAL frog_dead_on : STD_LOGIC;
	SIGNAL win_on : STD_LOGIC;
	SIGNAL frog_deadx  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL frog_deady  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(580, 11);
	-- current frog position - intitialized to center of screen
	SIGNAL frog_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
	SIGNAL frog_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(580, 11);
	-- goal coordinates
	SIGNAL goal_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100, 11);
	-- current frog motion - initialized to +4 pixels/frame
	SIGNAL frog_hop : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000100";
	SIGNAL direction  : INTEGER := 8;
-- signals and variables for cars
    CONSTANT car_size  : INTEGER := 12;
	SIGNAL car1_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car1_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car1_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(250, 11);
	-- current car motion - initialized to +3 pixels/frame
	SIGNAL car1_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "10100100011";
	-- car 2 -
	SIGNAL car2_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car2_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car2_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
	-- current car motion - initialized to +4 pixels/frame
	SIGNAL car2_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01011100100";
	-- car 3 -
	SIGNAL car3_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car3_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(10, 11);
	SIGNAL car3_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(350, 11);
	-- current car motion - initialized to +5 pixels/frame
	SIGNAL car3_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01110010111";	
	-- car 4 -
	SIGNAL car4_on : STD_LOGIC; -- indicates whether car1 is over current pixel position
	-- current car position 
	SIGNAL car4_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(20, 11);
	SIGNAL car4_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(150, 11);
	-- current car motion - initialized to +5 pixels/frame
	SIGNAL car4_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "11110001001";
	-- car 5 -
	SIGNAL car5_on : STD_LOGIC; -- indicates whether car5 is over current pixel position
	-- current car position 
	SIGNAL car5_x  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(30, 11);
	SIGNAL car5_y  : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(200, 11);
	-- current car motion - initialized to +5 pixels/frame
	SIGNAL car5_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000001101";	
	SIGNAL s_score : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000000";
	SIGNAL score_incr : STD_LOGIC_VECTOR(15 DOWNTO 0) := "0000000000000001";
		
BEGIN
	-- THIS IS WHERE THE COLORS WERE DONE FOR DRAWING -- WILL CHANGE TO EJ'S METHOD TOMORROW & ADD THE CONSTRAINT CODE 
    red <= (NOT frog_on or win_on); -- color setup for red ball and cyan bat on white background
    green <= NOT(car1_on or car2_on or car3_on or car4_on or car5_on or frog_dead_on);
    blue <= win_on or NOT(car1_on or car2_on or car3_on or car4_on or car5_on or frog_dead_on);
    
    score <= s_score;
	-- process to draw frog current pixel address is covered by frog position
	fdraw : PROCESS (frog_x, frog_y, pixel_row, pixel_col, frog_dead, win) IS
	BEGIN
	    IF NOT (frog_dead = '1' OR win = '1') THEN
		IF (pixel_col >= frog_x - size) AND
		   (pixel_col <= frog_x + size) AND
		   (pixel_row >= frog_y - size) AND
	  	   (pixel_row <= frog_y + size) THEN
			frog_on <= '1';
		ELSE
			frog_on <= '0';
		END IF;
		ELSIF frog_dead = '1' THEN
		IF (pixel_col >= frog_deadx - size) AND
		   (pixel_col <= frog_deadx + size) AND
		   (pixel_row >= frog_deady - size) AND
	  	   (pixel_row <= frog_deady + size) THEN
			frog_dead_on <= '1';
			frog_on <= '0';
	    ELSIF win = '1' THEN
	       IF (pixel_col >= frog_deadx - size) AND
		   (pixel_col <= frog_deadx + size) AND
		   (pixel_row >= frog_deady - size) AND
	  	   (pixel_row <= frog_deady + size) THEN
			win_on <= '1'; 
			frog_on <= '0';
		END IF;
		END IF;
		END IF;
		END PROCESS;
		
	-- process to move frog once every frame (i.e. once every vsync pulse)
	mfrog : PROCESS
	BEGIN
	   WAIT UNTIL rising_edge(v_sync);
	   IF up = '1' THEN
	       direction <= 1;
	   ELSIF down = '1' THEN
	       direction <= 2;
	   ELSIF left = '1' THEN
	       direction <= 3;
	   ELSIF right = '1' THEN
	       direction <= 4;
	   ELSIF reset = '1' THEN
	       direction <= 5;
	   ELSE
	       direction <= 0;
	   END IF;
	   
	   IF direction = 1 THEN
	       frog_y <= frog_y - frog_hop;
	   ELSIF direction = 2 THEN
	       frog_y <= frog_y + frog_hop;
	   ELSIF direction = 3 THEN
	       frog_x <= frog_x - frog_hop;
	   ELSIF direction = 4 THEN
	       frog_x <= frog_x + frog_hop;
	   ELSIF direction = 5 THEN
	       frog_x <= CONV_STD_LOGIC_VECTOR(400, 11);
           frog_y <= CONV_STD_LOGIC_VECTOR(580, 11);
           frog_dead <= '0';
           win <= '0';
	   ELSIF direction = 0 THEN
	       frog_x <= frog_x;  
	   END IF;  
	   --- collision detection for car1, 2 and 3
	   IF ((frog_x >= car1_x - 15 AND frog_x <= car1_x + 15) 
       AND (frog_y >= car1_y - 15 AND frog_y <= car1_y + 15)) OR 
       ((frog_x >= car2_x - 15 AND frog_x <= car2_x + 15) 
       AND (frog_y >= car2_y - 15 AND frog_y <= car2_y + 15)) OR
       ((frog_x >= car3_x - 15 AND frog_x <= car3_x + 15) 
       AND (frog_y >= car3_y - 15 AND frog_y <= car3_y + 15)) OR
       ((frog_x >= car4_x - 15 AND frog_x <= car4_x + 15) 
       AND (frog_y >= car4_y - 15 AND frog_y <= car4_y + 15)) OR
       ((frog_x >= car5_x - 15 AND frog_x <= car5_x + 15) 
       AND (frog_y >= car5_y - 15 AND frog_y <= car5_y + 15))
       THEN
           s_score <= CONV_STD_LOGIC_VECTOR(0, 16);
           frog_dead <= '1';
           frog_deadx <= frog_x;
           frog_deady <= frog_y;
       ELSIF (frog_y <= goal_y) THEN
           IF win = '0' THEN
            s_score <= s_score + score_incr;	
           END IF;
           win <= '1';
           frog_deadx <= frog_x;
           frog_deady <= frog_y; 	   
       END IF;
	   END PROCESS;
	   
	--process to draw cars
	c1draw : PROCESS (car1_x, car1_y, pixel_row, pixel_col) IS
	BEGIN
		IF (pixel_col >= car1_x - size) AND
		 (pixel_col <= car1_x + size) AND
			 (pixel_row >= car1_y - size) AND
			 (pixel_row <= car1_y + size) THEN
				car1_on <= '1';
		ELSE
			car1_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car1 once every frame (i.e. once every vsync pulse)
		mcar1 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car1_x + size >= 800 THEN
				car1_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car1_x <= size THEN
				car1_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car1_x <= car1_x + car1_x_motion; -- compute next car1 position
		END PROCESS;
		
		c2draw : PROCESS (car2_x, car2_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car2_x - size) AND
		 (pixel_col <= car2_x + size) AND
			 (pixel_row >= car2_y - size) AND
			 (pixel_row <= car2_y + size) THEN
				car2_on <= '1';
		ELSE
			car2_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car2 once every frame (i.e. once every vsync pulse)
		mcar2 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car2_x + size >= 800 THEN
				car2_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car2_x <= size THEN
				car2_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car2_x <= car2_x + car2_x_motion; -- compute next car2 position
		END PROCESS;
		c3draw : PROCESS (car3_x, car3_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car3_x - size) AND
		 (pixel_col <= car3_x + size) AND
			 (pixel_row >= car3_y - size) AND
			 (pixel_row <= car3_y + size) THEN
				car3_on <= '1';
		ELSE
			car3_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car3 once every frame (i.e. once every vsync pulse)
		mcar3 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car3_x + size >= 800 THEN
				car3_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car3_x <= size THEN
				car3_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car3_x <= car3_x + car3_x_motion; -- compute next car3 position
		END PROCESS;
		c4draw : PROCESS (car4_x, car4_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car4_x - size) AND
		 (pixel_col <= car4_x + size) AND
			 (pixel_row >= car4_y - size) AND
			 (pixel_row <= car4_y + size) THEN
				car4_on <= '1';
		ELSE
			car4_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car3 once every frame (i.e. once every vsync pulse)
		mcar4 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car4_x + size >= 800 THEN
				car4_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car4_x <= size THEN
				car4_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car4_x <= car4_x + car4_x_motion; -- compute next car3 position
		END PROCESS;
		c5draw : PROCESS (car5_x, car5_y, pixel_row, pixel_col) IS
	   BEGIN
		IF (pixel_col >= car5_x - size) AND
		 (pixel_col <= car5_x + size) AND
			 (pixel_row >= car5_y - size) AND
			 (pixel_row <= car5_y + size) THEN
				car5_on <= '1';
		ELSE
			car5_on <= '0';
		END IF;
		END PROCESS;
		-- process to move car3 once every frame (i.e. once every vsync pulse)
		mcar5 : PROCESS
		BEGIN
			WAIT UNTIL rising_edge(v_sync);
			-- allow for bounce off top or bottom of screen
			IF car5_x + size >= 800 THEN
				car5_x_motion <= "11111111100"; -- -4 pixels
			ELSIF car5_x <= size THEN
				car5_x_motion <= "00000000100"; -- +4 pixels
			END IF;
			car5_x <= car5_x + car5_x_motion; -- compute next car3 position
		END PROCESS;
END Behavioral;

