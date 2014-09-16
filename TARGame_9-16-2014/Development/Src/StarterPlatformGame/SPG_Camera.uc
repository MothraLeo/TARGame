//=============================================================================
// SPG_Camera
//
// Camera which simply adds an offset to the target's location and aims
// the camera at the target.
//
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class SPG_Camera extends Camera;

var const archetype SPG_CameraProperties CameraProperties;

var float CameraDistanceX;

var int PanSpeedModY, PanSpeedModZ;

var rotator CurrentCameraRotation;

var vector CurrentCameraLocation, DesiredCameraLocation, Offset;

var Pawn PC;

/**
 * Updates the camera's view target. Called once per tick
 *
 * @param	OutVT		Outputted camera view target
 * @param	DeltaTime	Time since the last tick was executed
 */


function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
    CameraDistanceX = CameraProperties.CameraDistanceX;
    PanSpeedModY = CameraProperties.PanSpeedModY;
    PanSpeedModZ = CameraProperties.PanSpeedModZ;
    Offset = CameraProperties.CameraOffset;
    PC = PCOwner.Pawn;

	// Early exit if:
	// - We have a pending view target
	// - OutVT currently equals ViewTarget
	// - Blending parameter is lock out going
	if (PendingViewTarget.Target != None && OutVT == ViewTarget && BlendParams.bLockOutgoing)
	{
		return;
	}

        // Take the current Pawn location, then apply the offset in the direction that the Pawn is facing via rotation -DMR
        DesiredCameraLocation = PC.Location + (Offset >> PC.Rotation);
        // Lock the X distance to keep camera from panning in and out. Creates the need for the Pawn to always be at 0 x,
        // which could prove troublesome. May need optimizing -DMR
        DesiredCameraLocation.x =  CameraDistanceX;
        // Move the came the camera toward its desired location at variable speeds for each axis -DMR
        CurrentCameraLocation.x += (DesiredCameraLocation.x - CurrentCameraLocation.x) * DeltaTime * 5;
        CurrentCameraLocation.y += (DesiredCameraLocation.y - CurrentCameraLocation.y) * DeltaTime * PanSpeedModY;
        CurrentCameraLocation.z += (DesiredCameraLocation.z - CurrentCameraLocation.z) * DeltaTime * PanSpeedModZ;
	// Set the output to the current camera location -DMR
	OutVT.POV.Location = CurrentCameraLocation;
	// Make the camera point towards the target's location
	OutVT.POV.Rotation = Rotator((OutVT.POV.Location * vect(0,1,1)) - OutVT.POV.Location);
}

/*
        This code is leftover from an experiment in adjusting the camera based on Pawn rotation. Feel free to use or remove
        it as you see fit, it currently just logs direction and the act of turning. -DMR

function Tick(float DeltaTime)
{
    if(PC != none && PC.Rotation.Yaw == 16384)
        GoToState('FacingRight');

    if(PC != none && PC.Rotation.Yaw == -16384)
        GoToState('FacingLeft');

    if(PC != none && PC.Rotation.Yaw > -16384 && PC.Rotation.Yaw < 16384)
        GoToState('Turning');
}

state Turning
{
    function BeginState(Name PreviousStateName)
    {
        `log("Turning");
    }
}

state FacingRight
{
    function BeginState(Name PreviousStateName)
    {
        `log("Facing Right");
    }
}

state FacingLeft
{
        function BeginState(Name PreviousStateName)
    {
        `log("Facing Left");
    }
}
*/


defaultproperties
{
	CameraProperties=SPG_CameraProperties'StarterPlatformGameContent.Archetypes.CameraProperties'
}