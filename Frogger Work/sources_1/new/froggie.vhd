-- snake_n_food.vhd

LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;

USE IEEE.STD_LOGIC_ARITH.ALL;

USE IEEE.STD_LOGIC_UNSIGNED.ALL;



ENTITY snake_n_food IS

	PORT (

		v_sync : IN STD_LOGIC;

		pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);

		pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);

		red : OUT STD_LOGIC;

		green : OUT STD_LOGIC;

		blue : OUT STD_LOGIC;
		
		-- movements
		
		left : IN STD_LOGIC;
		
		right : IN STD_LOGIC;
		
		up : IN STD_LOGIC;
		
		down : IN STD_LOGIC;
		
		reset : IN STD_LOGIC
		
	);

END snake_n_food;



ARCHITECTURE Behavioral OF snake_n_food IS

	CONSTANT size : INTEGER := 8;

	SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is over current pixel position

	-- current ball position - intitialized to center of screen

	SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320, 11);

	SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240, 11);

	-- current ball motion - initialized to +4 pixels/frame

	SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0);
	
	SIGNAL ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0);
	
	-- direction and ball speed and food variables
	
	SIGNAL direction : INTEGER := 8;
	
	SIGNAL ball_speed_stop : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000000";
	
	SIGNAL ball_speed_positive : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000001";
	
	SIGNAL ball_speed_negative : STD_LOGIC_VECTOR(10 DOWNTO 0) := "11111111111";
	
	
	CONSTANT food_size : INTEGER := 8;

	SIGNAL food_on : STD_LOGIC;

    SIGNAL food_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50,11);
    
    SIGNAL food_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50,11);

BEGIN

	red <= NOT ball_on; -- color setup for red ball on white background

	green <= food_on;

	blue <= '1';

	-- process to draw ball current pixel address is covered by ball position

	bdraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS

	BEGIN

		IF(pixel_col >= ball_x - size) AND
		  (pixel_col <= ball_x + size) AND
		  (pixel_row >= ball_y - size) AND
		  (pixel_row <= ball_y + size) THEN
		      ball_on <= '1';

		ELSE

			ball_on <= '0';

		END IF;

		END PROCESS;

		-- process to move ball once every frame (i.e. once every vsync pulse)
		
		-- draw the food 
		
	fdraw: PROCESS (food_x, food_y, pixel_row, pixel_col)
	   
	BEGIN
	
	   	IF((CONV_INTEGER(Pixel_col)-CONV_INTEGER(food_x))*
		(CONV_INTEGER(Pixel_col)-CONV_INTEGER(food_x))+
		(CONV_INTEGER(Pixel_row)-CONV_INTEGER(food_y))*
		(CONV_INTEGER(Pixel_row)-CONV_INTEGER(food_y)))<=
		CONV_INTEGER(food_size)*CONV_INTEGER(size)then
		      food_on <= '1';

		ELSE

			food_on <= '0';

		END IF;

		END PROCESS;
		

		mball : PROCESS

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
		          
		   END IF;
		   
		   -- if there is no direction chosen then do not move the snake
		   
		   IF direction = 0 THEN
		      
		      ball_x_motion <= ball_speed_stop;
		      
		      ball_y_motion <= ball_speed_stop;
		      
		   END IF;
		   
		   -- if a vertical direction is pressed
		   
		   IF direction = 1 THEN
		      
		      ball_y_motion <= ball_speed_negative;
		      
		   ELSIF direction = 2 THEN
		   
		      ball_y_motion <= ball_speed_positive;
		      
		   ELSIF direction = 3 OR direction = 4 THEN
		   
		      ball_y_motion <= ball_speed_stop;
		      
		   END IF;
		   
		   -- if a horizontal direction is pressed
		   
		   IF direction = 3 THEN
		   
		      ball_x_motion <= ball_speed_negative;
		      
		   ELSIF direction = 4 THEN
		   
		      ball_x_motion <= ball_speed_positive;
		      
		   ELSIF direction = 1 OR direction = 2 THEN
		   
		      ball_x_motion <= ball_speed_stop;
		      
		   END IF;
		   
		   -- changes the position of the ball
		   
		   ball_y <= ball_y + ball_y_motion;
		   ball_x <= ball_x + ball_x_motion;
		   
		   -- sets the horizontal ball variables when the game initially starts
		   
		   IF ball_x <= size OR ball_x >= 640 THEN
		   
		      ball_x <= CONV_STD_LOGIC_VECTOR(320,11);
		      
		      ball_y <= CONV_STD_LOGIC_VECTOR(240, 11);
		      
		      direction <= 0;
		      
		      ball_speed_positive <= "00000000001";
		      
		      ball_speed_negative <= "11111111111";
		      
		  END IF;
		  
		  -- sets the vertical ball variables when the game initially starts
		  
		  IF ball_y <= size OR ball_y >= 480 THEN
		   
		      ball_x <= CONV_STD_LOGIC_VECTOR(320,11);
		      
		      ball_y <= CONV_STD_LOGIC_VECTOR(240, 11);
		      
		      direction <= 0;
		      
		      ball_speed_positive <= "00000000001";
		      
		      ball_speed_negative <= "11111111111";
		      
		  END IF;
		  
		 -- when the reset button is pressed the game does to the initial setting again
		 
		 IF reset = '1' THEN
		 
		      ball_x <= CONV_STD_LOGIC_VECTOR(320,11);
		      
		      ball_y <= CONV_STD_LOGIC_VECTOR(240, 11);
		      
		      direction <= 0;
		      
		      ball_speed_positive <= "00000000001";
		      
		      ball_speed_negative <= "11111111111";
		      
		 END IF;
		 
		 -- changes the location of the food to the set 5 locations
		 
		 -- here is where an edit can be made to make the food appear at random locations
		 
		 IF (ball_x >= food_x - 15 AND ball_x <= food_x + 15) AND (ball_y >= food_y - 15 AND ball_y <= food_y + 15) THEN
		 
		      IF (food_x = CONV_STD_LOGIC_VECTOR(50, 11) AND food_y = CONV_STD_LOGIC_VECTOR(50,11)) THEN
		          
		          food_x <= CONV_STD_LOGIC_VECTOR(200,11);
		          
		          food_y <= CONV_STD_LOGIC_VECTOR(300,11);
		          
		      END IF;
		      
		      IF (food_x = CONV_STD_LOGIC_VECTOR(200, 11) AND food_y = CONV_STD_LOGIC_VECTOR(300,11)) THEN
		          
		          food_x <= CONV_STD_LOGIC_VECTOR(150,11);
		          
		          food_y <= CONV_STD_LOGIC_VECTOR(100,11);
		          
		      END IF;
		      
		      IF (food_x = CONV_STD_LOGIC_VECTOR(150, 11) AND food_y = CONV_STD_LOGIC_VECTOR(100,11)) THEN
		          
		          food_x <= CONV_STD_LOGIC_VECTOR(200,11);
		          
		          food_y <= CONV_STD_LOGIC_VECTOR(80,11);
		          
		      END IF;
		      
		      IF (food_x = CONV_STD_LOGIC_VECTOR(200, 11) AND food_y = CONV_STD_LOGIC_VECTOR(80,11)) THEN
		          
		          food_x <= CONV_STD_LOGIC_VECTOR(50,11);
		          
		          food_y <= CONV_STD_LOGIC_VECTOR(50,11);
		          
		      END IF;
		      
		      -- finally increment the speed of the snake to increase
		      
		      ball_speed_positive <= ball_speed_positive + "00000000001";
		      
		      ball_speed_negative <= ball_speed_negative + "11111111111";
		      
		 END IF;

		END PROCESS;

END Behavioral;

