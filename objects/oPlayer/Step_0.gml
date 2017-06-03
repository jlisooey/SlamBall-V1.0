/// Movement

// Input //////////////////////////////////////////////////////////////////////

var kLeft, kRight, kUp, kDown, kJump, kJumpRelease, kLeap, kLeapRelease, kAction, kShoot, kShootRelease, kShuffle, kRollR, tempAccel, tempFric;

kLeft          = keyboard_check(vk_left)  || gamepad_axis_value(controller, gp_axislh) < -0.4;
kRight         = keyboard_check(vk_right) || gamepad_axis_value(controller, gp_axislh) >  0.4;
kUp            = keyboard_check(vk_up)    || gamepad_axis_value(controller, gp_axislv) < -0.4;
kDown          = keyboard_check(vk_down)  || gamepad_axis_value(controller, gp_axislv) >  0.4;

kJump          = keyboard_check_pressed(ord("S"))  || gamepad_button_check_pressed(controller, gp_face1);
kJumpRelease   = keyboard_check_released(ord("S")) || gamepad_button_check_released(controller, gp_face1);
kLeap          = keyboard_check_pressed(ord("C"))  || gamepad_button_check_pressed(controller, gp_face2);
kLeapRelease   = keyboard_check_released(ord("C")) || gamepad_button_check_released(controller, gp_face2);

kAction        = keyboard_check_pressed(ord("W"))  || gamepad_button_check_pressed(controller, gp_face3);
kShoot         = keyboard_check(ord("E"))          || gamepad_button_check(controller, gp_face3);  
kShootRelease  = keyboard_check_released(ord("E")) || gamepad_button_check_released(controller, gp_face3);
kShuffle       = keyboard_check(ord("A"))	       || gamepad_button_check(controller, gp_shoulderlb);
kRollR         = keyboard_check_pressed(ord("D"))  || gamepad_button_check_pressed(controller, gp_shoulderrb);

// Movement ///////////////////////////////////////////////////////////////////

// Get last facing
facingPrev = facing;

// Apply the correct form of acceleration and friction
if (onGround) {
	jumpCount = 0; 
	rollCount = 0; 
    tempAccel = groundAccel;
    tempFric  = groundFric;
} else {
    tempAccel = airAccel;
    tempFric  = airFric;
}

// Reset wall cling
if ((!cRight && !cLeft) || onGround) {
    canStick = true;
    sticking = false;
}   

// Cling to wall
if (((kRight && cLeft) || (kLeft && cRight)) && canStick && !onGround) {
    alarm[0] = clingTime;
    sticking = true; 
    canStick = false;
	jumpCount = 0;       
}

// Handle gravity
if (!onGround and (state != ROLL)) {
    if(state = SHOOTING){
		vy = Approach(vy, vyMax, gravShot);
	}else if ((cLeft || cRight) && vy >= 0) {
        // Wall slide
        vy = Approach(vy, vyMax, gravSlide);
    } else {
        // Fall normally
        vy = Approach(vy, vyMax, gravNorm);
    }
}

if (state != ROLL and state !=SHOOTING) {
// Left 
if (kLeft && !kRight && !sticking) {
    facing = -1;
    state  = RUN;
    
    // Apply acceleration left
    if (vx > 0)
        vx = Approach(vx, 0, tempFric);   
    vx = Approach(vx, -vxMax, tempAccel);
// Right
} else if (kRight && !kLeft && !sticking) {
    facing = 1;
    state  = RUN;
    
    // Apply acceleration right
    if (vx < 0)
        vx = Approach(vx, 0, tempFric);   
    vx = Approach(vx, vxMax, tempAccel);
}
}

// Friction
if (!kRight && !kLeft) {
    vx = Approach(vx, 0, tempFric);
    
    if (state != ROLL and state != SHOOTING)
        state = IDLE;
} 
       
// Wall jump
if (kJump && cLeft && !onGround) {
    yscale = 1.33;
    xscale = 0.67;
	++jumpCount;
            
    if (kLeft) {
        vy = -jumpHeight * 1.2;
        vx =  jumpHeight * .66;
    } else {
        vy = -jumpHeight * 1.1;
        vx =  vxMax; 
    }  
}

if (kJump && cRight && !onGround) {
    yscale = 1.33;
    xscale = 0.67;
	++jumpCount;
    
    if (kRight) {
        vy = -jumpHeight * 1.2;
        vx = -jumpHeight * .66;
    } else {
        vy = -jumpHeight * 1.1;
        vx = -vxMax;
    }  
}
 
// Jump 
if (kJump) {
	//first jump 
    if (onGround) {
        yscale = 1.33;
        xscale = 0.67;
		++jumpCount;
		
		if (kRight) {
			vy = -jumpHeight;
			vx = jumpHeight * .3;
		} else if (kLeft) {
			vy = -jumpHeight;
			vx = -jumpHeight * .3;
		} else {
			vy = -jumpHeight;
		} 
		
	//Double Jump
    }else if(jumpCount<2){
        yscale = 1.33;
        xscale = 0.67;
		++jumpCount;
		
		if (kRight) {
			vy = -jumpHeight;
			vx = jumpHeight * .3;
		} else if (kLeft) {
			vy = -jumpHeight;
			vx = -jumpHeight * .3;
		} else {
			vy = -jumpHeight;
		} 
	}
// Variable jumping
} else if (kJumpRelease) { 
    if (vy < 0){
        vy *= 0.5;
	}
}

// Leap 
if (kLeap and !possession and jumpCount<3) {
	//first jump 
    yscale = 1.33;
    xscale = 0.67;
	jumpCount = 10;
		
	if (kRight) {
		vy = -leapHeight* .75;
		vx = leapHeight;
	} else if (kLeft) {
		vy = -leapHeight* .75;
		vx = -leapHeight;
	} else {
		vx = (facing)*leapHeight;
		vy = -leapHeight* .75;
	}
// Variable jumping
} else if (kLeapRelease) { 
    if (vy < 0){
        vy *= 0.75;
	}
}


if (onGround) {
        // Fall thru platform
    if (kDown) {
        if (place_meeting(x, y + 4, oParJumpThru)){
            ++y;
		}
	}
}

// Jump state
if (!onGround and (state != ROLL) and state != SHOOTING)
    state = JUMP;
// Run particles
else if (random(100) > 85 && abs(vx) > 0.5)
    instance_create(x, y + 8, oParticlePlayer);

// Swap facing during wall slide
if (cRight && !onGround && (state!=ROLL)and state != SHOOTING)
    facing = -1;
else if (cLeft && !onGround && (state!=ROLL)and state != SHOOTING)
    facing = 1;

//attack
if (kAction and state!=ROLL and !possession and !attacking and canAttack) {
	attacking = true;
	canAttack = false;
	effects_ScreenShake(2,2,5);
	ins_attack = instance_create(x, y, oPlayerAtkMask);
	ins_attack.player_id = id;
	ins_attack.attackTime = 20;
	ins_attack.attackSizeX = 2.5;
	ins_attack.attackSizeY = 2.5;
	vx = 0;
	vy = 0;
	
	if(kUp){
		ins_attack.acc_y = -6;
	}else if(kDown){
		ins_attack.acc_y = 6;
		vy = -2*sign(ins_attack.acc_y);
	}else if(kRight){
		ins_attack.acc_x = 6;
	}else if(kLeft){
		ins_attack.acc_x = -6;
	}else{
		ins_attack.acc_x = (facing)*6;
	}
	
	vx = -2*sign(ins_attack.acc_x);
	
}


// shot charging
if (kShoot and state!=ROLL and !cancel and !attacking) {
	if(possession){
		//increase shotpower
		shotPower+=2.5;
		facing = team;
		
		//can't move while shooting and apply shooting gravity
		if(state!=SHOOTING){
			vy = 0; 
			vy = Approach(vy, vyMax, gravShot);
			vx = (-1)*team*3;
		}else{
			vx = 0;
		}
		state = SHOOTING;
		//vy = Approach(vy, vyMax, gravShot); vx = 0;	
	}
}


// Roll
//if (onGround && !attacking) {
if (!attacking) {
    if (state != ROLL) {
        /*if (kRollL) {
            facing = -1;
            
            image_index  = 0;
            image_speed  = 0.5;
            sprite_index = sPlayerRoll;
            
            state = ROLL;
        } else*/ 
		if (kRollR and rollCount<2) {
			if(!onGround){
				rollCount++;
			}
			if(kLeft || kRight){
				facing = 1 - (kLeft*2);
            }else{
				facing = facingPrev;
			}				
			
			//add screenshake for roll duration (14 frames)
			if(onGround){
				effects_ScreenShake(0,1,14);
			}else{
				effects_ScreenShake(0,1,5);
			}
            image_index  = 0;
            image_speed  = 0.5;
            sprite_index = sPlayerRoll;
            if(state = SHOOTING){
				cancel = true;
			}			
			
            state = ROLL;
        }
    }
}

// Roll speed
if (state == ROLL) {
	if(onGround){
		vx = facing * 6;
	}else{
		vx = facing * 4;
	}
    vy = 0;
    // Break out of roll
        //if (!onGround || (cLeft || cRight)) {
	if ((cLeft || cRight)) {
        state = IDLE;
        if (!attacking){
            alarm[1] = -1;
		}
    }
}

// shuffle
if(kShuffle and state != ROLL and state != SHOOTING){
	facing = team;
}
    
//Shoot Ball
if(kShootRelease and possession and !attacking){
	if(cancel){
		cancel = false;
		state = IDLE;
		shotPower = 0;
	}else{
		effectpower = (shotPower+shotInitial)/35;
		effectpower = min(effectpower,5);
		state = IDLE;
		possession = false;
		insBall = instance_create(x,y-8,oBall);
		if(shotPower<30){
			vx = (-1)*team*5;
			shotPower = shotInitial + 20;
			insBall.shotPower = shotPower;
			insBall.shotType = 12;
			effects_ScreenShake(3,3,5);
		}else{
			vx = (-1)*team*(effectpower+1);
			shotPower = shotInitial + shotPower;
			shotPower = min(shotPower,250)
			insBall.shotPower = shotPower;
			insBall.shotType = 14;
			effects_ScreenShake(effectpower,effectpower,5);
		}
		insBall.targetGoal = targetGoal;
		insBall.shotDirection = team;
		shotPower = 0;
	}
}

if(kShootRelease){
	attacking = false;
}

/* */
/// Squash + stretch
xscale = Approach(xscale, 1, 0.05);
yscale = Approach(yscale, 1, 0.05);

/* */
/// Hitbox

with (oPlayerAtkBox)
    instance_destroy();

// Dash out of roll
if (sprite_index == sPlayerRollSlash) {    
    with (instance_create(x, y, oPlayerAtkBox)) {
        bboxleft  = min(other.x + (5 * other.facing), other.x + (24 * other.facing));
        bboxright = max(other.x + (5 * other.facing), other.x + (24 * other.facing));
        
        bboxtop    = other.y - 1;
        bboxbottom = other.y + 8; 
    }
}
    
// Jab
if (sprite_index == sPlayerJab && round(image_index) > 0) {    
    with (instance_create(x, y, oPlayerAtkBox)) {
        bboxleft  = min(other.x + (5 * other.facing), other.x + (30 * other.facing));
        bboxright = max(other.x + (5 * other.facing), other.x + (30 * other.facing));
        
        bboxtop    = other.y - 1;
        bboxbottom = other.y + 8; 
    }
}

//need to add facingBeforeRoll
if(state = SHOOTING){
	facing = team;
}else if(!onGround and state != ROLL){
	facing = facingPrev;
}

/* */
/*  */
