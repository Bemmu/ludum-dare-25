/*
montage 0001.png 0002.png 0003.png 0004.png 0005.png 0006.png 0007.png 0008.png 0009.png 0010.png 0011.png 0012.png 0013.png 0014.png 0015.png 0016.png 0017.png 0018.png 0019.png 0020.png 0021.png 0022.png 0023.png 0024.png 0025.png 0026.png 0027.png 0028.png 0029.png 0030.png 0031.png 0032.png 0033.png 0034.png 0035.png -tile 1x -geometry 230x -background Transparent goo.png
*/

package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;

	public class Game extends Sprite {
		var keys = {};
		var roadBitmap = null;
		var headlights = null;
		var ballShadow = null;
		var billboardsBitmap = null;
		var roadRef = null;

		var combo;
		var controlStrength;		
		var drag;
		var xs;
		var targetSpeedRoadPixelsPerSecond;
		var roadGenerationWidth;
		var roadBitmapData;
		var ball;
		var ballFrames;
		var ballBuffer;
		var billboardBuffer;
		var player;
		var pipipi = new Pipipi();
		var pixelsUntilCheckpoint;
		var timeleft;
		var totalPixelsTraveled;
		var totalTimeSpent;
		var didGameover;
		var obstacles;
		var inited;
		var lastRefreshStart;
		var speedRoadPixelsPerSecond;
		var checkpointI;
		var checkpointCrossedI;

		var roadTypes = {
			'mainRoad' : function (that, pixels) {
				var roadX = 0;
				var roadWidth = that.roadGenerationWidth * (Math.random() * 0.1 + 0.9);
				var h = pixels;
				var grassNoise = new BitmapData(that.roadBitmapData.width, h);
				grassNoise.noise(getTimer(), 40, 255, BitmapDataChannel.GREEN);
				that.roadBitmapData.copyPixels(grassNoise, grassNoise.rect, new Point(0, 0));

				var asphaltBitmap = new BitmapData(roadWidth, h);
				asphaltBitmap.noise(getTimer(), 0, 50, 0x17, true);
				that.roadBitmapData.copyPixels(asphaltBitmap, asphaltBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX - roadWidth/2, 0));

				var roadBorder = 5;
				var sidelineBitmap = new BitmapData(roadBorder, h, true);
				sidelineBitmap.noise(getTimer(), 100, 255, BitmapDataChannel.ALPHA, true);
				that.roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX - roadWidth/2, 0));
				that.roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX + roadWidth/2 - roadBorder, 0));
			},
			'icyRoad' : function (that, pixels) {
				var roadX = 0;
				var roadWidth = that.roadGenerationWidth * (Math.random() * 0.1 + 0.9);
				var h = pixels;
				var grassNoise = new BitmapData(that.roadBitmapData.width, h);
				grassNoise.noise(getTimer(), 40, 255, BitmapDataChannel.GREEN);
				that.roadBitmapData.copyPixels(grassNoise, grassNoise.rect, new Point(0, 0));

				var asphaltBitmap = new BitmapData(roadWidth, h);
				asphaltBitmap.noise(getTimer(), 100, 255, BitmapDataChannel.BLUE, false);
				that.roadBitmapData.copyPixels(asphaltBitmap, asphaltBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX - roadWidth/2, 0));

				var roadBorder = 5;
				var sidelineBitmap = new BitmapData(roadBorder, h, true);
				sidelineBitmap.noise(getTimer(), 100, 255, BitmapDataChannel.ALPHA, true);
				that.roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX - roadWidth/2, 0));
				that.roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX + roadWidth/2 - roadBorder, 0));
			},
			'dirt' : function (that, pixels) {
				var roadX = 0;
				var roadWidth = that.roadGenerationWidth * (Math.random() * 0.3 + 0.7);
				var h = pixels;
				var grassNoise = new BitmapData(that.roadBitmapData.width, h);
				grassNoise.noise(getTimer(), 40, 255, 0x17, true);
				that.roadBitmapData.copyPixels(grassNoise, grassNoise.rect, new Point(0, 0));

/*				var asphaltBitmap = new BitmapData(roadWidth, h);
				asphaltBitmap.noise(getTimer(), 0, 50, 0x17, true);
				that.roadBitmapData.copyPixels(asphaltBitmap, asphaltBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX - roadWidth/2, 0));
*/
				var roadBorder = 5;
				var sidelineBitmap = new BitmapData(roadBorder, h, true);
				sidelineBitmap.noise(getTimer(), 100, 255, BitmapDataChannel.ALPHA, true);
				that.roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX - roadWidth/2, 0));
				that.roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(that.roadBitmapData.width/2 + roadX + roadWidth/2 - roadBorder, 0));
			}
		};

		var levels = [
			{
				'name' : 'Click here. Then WASD/Arrow keys.',
				'distance' : 750,
				'timebonus' : 20,
				'tick' : function (that) {
				},
				'init' : function (that) { 
					that.controlStrength = 1;
					that.drag = 0.85;
				},
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : 'You are grey goo. Towards city, turn it into you!',
				'distance' : 750,
				'timebonus' : 20,
				'tick' : function (that) {
				},
				'init' : function (that) {
				},
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : 'Red things slow you down.',
				'distance' : 2000,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
					type = 'slowdown';
					color = 0xffff0000;
					sound = new Slowdown();
					roadSpaceSize = new Point(10, 10);
					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					/* else {
						type = 'speedup';
						color = 0xff00ff00;
						sound = new Speedup();
						roadSpaceSize = new Point(10, 10);
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					}*/
					if (Math.random() < 0.07) {
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
			},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : '',
				'distance' : 2000,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
					type = 'slowdown';
					color = 0xffff0000;
					sound = new Slowdown();
					roadSpaceSize = new Point(10, 10);
//					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					var xp = Math.sin(0.5 + that.totalPixelsTraveled/50.0)*0.3;
					if (Math.random() < 0.5) {
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (xp-0.4)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (0.4+xp)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : 'Green things give a speedup.',
				'distance' : 3000,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
/*					if (Math.random() < 0.5) {
						type = 'slowdown';
						color = 0xffff0000;
						sound = new Slowdown();
						roadSpaceSize = new Point(10, 10);
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					} else {*/
						type = 'speedup';
						color = 0xff00ff00;
						sound = new Speedup();
						roadSpaceSize = new Point(10, 10);
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
//					}
					if (((that.totalPixelsTraveled/5)%10) == 0) {
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : '',
				'distance' : 4000,
				'timebonus' : 32,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;

					type = 'speedup';
					color = 0xff00ff00;
					sound = new Speedup();
					roadSpaceSize = new Point(10, 10);
					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					if (((that.totalPixelsTraveled/5)%10) == 0) {
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}

					type = 'slowdown';
					color = 0xffff0000;
					sound = new Slowdown();
					roadSpaceSize = new Point(10, 10);
//					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					var xp = Math.sin(0.5 + that.totalPixelsTraveled/50.0)*0.3;
					if (Math.random() < 0.5) {
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (xp-0.4)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (0.4+xp)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},			
			{
				'name' : '',
				'distance' : 1200,
				'timebonus' : 20,
				'tick' : function (that) {
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : 'Oh no, icy road!',
				'distance' : 2300,
				'timebonus' : 15,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
					if (Math.random() < 0.5) {
						type = 'slowdown';
						color = 0xffff0000;
						sound = new Slowdown();
						roadSpaceSize = new Point(10, 10);
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					} else {
						type = 'speedup';
						color = 0xff00ff00;
						sound = new Speedup();
						roadSpaceSize = new Point(10, 10);
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					}
					if (Math.random() < 0.05) {
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) {
					that.controlStrength = 0.2;
					that.drag = 1;
				},
				'drawRoad' : roadTypes['icyRoad']
			},
			{
				'name' : '',
				'distance' : 2000,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
					type = 'slowdown';
					color = 0xffff0000;
					sound = new Slowdown();
					roadSpaceSize = new Point(10, 10);
//					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					var xp = Math.sin(0.5 + that.totalPixelsTraveled/50.0)*0.3;
					if (Math.random() < 0.5) {
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (xp-0.4)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (0.4+xp)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['icyRoad']
			},
			{
				'name' : '',
				'distance' : 2000,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
					type = 'slowdown';
					color = 0xffff0000;
					sound = new Slowdown();
					roadSpaceSize = new Point(10, 10);
//					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					var xp = Math.sin(0.5 + that.totalPixelsTraveled/50.0)*0.3 + Math.cos(0.5 + that.totalPixelsTraveled/35.0)*0.3;
					if (Math.random() < 0.5) {
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (xp-0.4)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (0.4+xp)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['icyRoad']
			},
			{
				'name' : '',
				'distance' : 2000,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;

					type = 'speedup';
					color = 0xff00ff00;
					sound = new Speedup();
					roadSpaceSize = new Point(10, 10);
					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					if (((that.totalPixelsTraveled/5)%10) == 0) {
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}

					type = 'slowdown';
					color = 0xffff0000;
					sound = new Slowdown();
					roadSpaceSize = new Point(10, 10);
//					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					var xp = Math.sin(0.5 + that.totalPixelsTraveled/50.0)*0.3 + Math.cos(0.5 + that.totalPixelsTraveled/35.0)*0.3;
					if (Math.random() < 0.5) {
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (xp-0.4)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (0.4+xp)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['icyRoad']
			},
			{
				'name' : '',
				'distance' : 1500,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
					type = 'speedup';
					color = 0xff00ff00;
					sound = new Speedup();
					roadSpaceSize = new Point(10, 10);
					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2, 0, 0);
					if (Math.random() < 0.15) {
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : '',
				'distance' : 2000,
				'timebonus' : 20,
				'tick' : function (that) {
					var type, color, sound, roadSpaceSize, roadSpacePosition;
					type = 'slowdown';
					color = 0xffff0000;
					sound = new Slowdown();
					roadSpaceSize = new Point(10, 10);
//					roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (Math.random() - 0.5)*that.roadGenerationWidth, 0, 0);
					var xp = Math.sin(0.5 + that.totalPixelsTraveled/50.0)*0.3 + Math.cos(0.5 + that.totalPixelsTraveled/40.0)*0.3;
					if (Math.random() < 0.5) {
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (xp-0.34)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
						roadSpacePosition = new Vector3D(that.roadBitmapData.width / 2 + (0.34+xp)*that.roadGenerationWidth, 0, 0);
						that.addObstacle({
							'roadSpacePosition' : roadSpacePosition,
							'roadSpaceSize' : roadSpaceSize,
							'type' : type,
							'color' : color,
							'sound' : sound
						});
					}
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['icyRoad']
			},
			{
				'name' : '',
				'distance' : 750,
				'timebonus' : 20,
				'tick' : function (that) {
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : '',
				'distance' : 1000,
				'timebonus' : 20,
				'tick' : function (that) {
				},
				'init' : function (that) { },
				'drawRoad' : roadTypes['mainRoad']
			},
			{
				'name' : 'City turns to goo! Villain wins.',
				'distance' : 2000,
				'timebonus' : 20,
				'percent' : 1,
				'tick' : function (that) {
					that.roadRef.transform.matrix3D.prependTranslation(0, 0, 2);
				},
				'init' : function (that) { 
					that.deleteNonPlayerObstacles();
					that.speedRoadPixelsPerSecond = 80;
					that.targetSpeedRoadPixelsPerSecond = 80;
					that.addObstacle({
						'roadSpacePosition' : new Vector3D(that.roadBitmapData.width / 2, -300, 250),
						'roadSpaceSize' : new Point(500, 250),
						'type' : 'city',
						'color' : 0xffffffff,
						'sound' : null
					});
				},
				'drawRoad' : roadTypes['mainRoad']
			}
		];


		function initVars() {
			combo = 0;
			win.visible = false;
			this.roadRef = road;
//			win.visible = false;
			win.city.gotoAndStop(0);

			if (roadBitmap) road.removeChild(roadBitmap);
			if (headlights) road.removeChild(headlights);
			if (ballShadow) removeChild(ballShadow);
			if (billboardsBitmap) removeChild(billboardsBitmap);

			lastRefreshStart = getTimer();
			totalTimeSpent = 0;
			timeleft = 0;
			xs = 0;
			totalPixelsTraveled = 0;
			roadGenerationWidth = 100;
			gameoverScreen.y = -stage.stageHeight;
			didGameover = false;
			obstacles = [];
			inited = false;
			speedRoadPixelsPerSecond = 80;
			targetSpeedRoadPixelsPerSecond = speedRoadPixelsPerSecond;
			checkpointI = 0;
			checkpointCrossedI = -1;

			roadBitmapData = new BitmapData(1024, 512, false);

			headlights = new Bitmap(new Headlights());
			headlights.width = roadBitmapData.width * 2;
			headlights.height = roadBitmapData.height;
			headlights.x = -(headlights.width - roadBitmapData.width)/2;

			ballFrames = new GooBall();						
			ballShadow = new Bitmap(new Shadow());

			billboardBuffer = new BitmapData(stage.stageWidth, stage.stageHeight + 50, true);

			player = {
				'type' : 'player',
				'roadSpacePosition' : new Vector3D(roadBitmapData.width / 2, roadBitmapData.height - 20, 0), // middle bottom
				'roadSpaceSize' : new Point(24, 48)
			};
			addObstacle(player);
			setNewCheckpointTimeleft();
			setNewCheckpointPos();
			billboardsBitmap = new Bitmap(billboardBuffer)
			roadBitmap = new Bitmap(roadBitmapData);

			road.addChild(roadBitmap);
			road.addChild(headlights);
			addChild(ballShadow);
			addChild(billboardsBitmap);

			checkpointTxt.visible = true;
			timeleftLabelTxt.visible = true;
			distanceTxt.visible = true;
			timeleftTxt.visible = true;
			win.visible = false;
			addChild(win);
			addChild(timeleftLabelTxt);
			addChild(distanceTxt);
			addChild(timeleftTxt);
			addChild(checkpointTxt); // bring to front
		}

		function restart() {
			initVars();
		}

/*		function drawRoad() {
			var h = 10;

			var grassNoise = new BitmapData(roadBitmapData.width, h);
			grassNoise.noise(getTimer(), 40, 255, BitmapDataChannel.GREEN);
			roadBitmapData.copyPixels(grassNoise, grassNoise.rect, new Point(0, 0));

			var roadX = Math.sin(getTimer()/100.0)*2 + Math.cos(getTimer()/500.0) * 40;
			var someNoise = new BitmapData(roadWidth, h);
			someNoise.noise(getTimer(), 240, 255, BitmapDataChannel.ALPHA);

			roadBitmapData.copyPixels(someNoise, someNoise.rect, new Point(roadBitmapData.width/2 + roadX - roadGenerationWidth/2, 0));
		}
*/
		function advanceRoad(pixels) {

			levels[checkpointCrossedI]['drawRoad'](this, pixels);

			// Advance the road
			roadBitmapData.copyPixels(roadBitmapData, roadBitmapData.rect, new Point(0, pixels));
		}

		function init() {
			advanceRoad(roadBitmapData.height);
		}

		function advanceObstacles(pixels) {
			for (var i = 0; i < obstacles.length; i++) {
				var o = obstacles[i];
				if (o['type'] == 'player') continue;
				o['roadSpacePosition'].y += pixels;
			}
		}

		function sortOrder(a, b) {
			if (a['roadSpacePosition'].y < b['roadSpacePosition'].y) {
				return -1;
			} else if (a['roadSpacePosition'].y > b['roadSpacePosition'].y) {
				return 1;
			} else {
				return 0;
			}
		}

		function sortObstacles() {
			obstacles.sort(sortOrder);
		}

		function billboards() {
			billboardBuffer.fillRect(billboardBuffer.rect, 0);
			sortObstacles();

			for (var i = 0; i < obstacles.length; i++) {
				var o = obstacles[i];
				if (o['deleted']) continue;

				var pos = o['roadSpacePosition'];
				var lowerLeftPos = new Vector3D(pos.x - o['roadSpaceSize'].x/2, pos.y, 0);
				var lowerRightPos = new Vector3D(pos.x + o['roadSpaceSize'].x/2, pos.y, 0);
				var lowerLeftPosOnScreen = road.local3DToGlobal(lowerLeftPos);
				var lowerRightPosOnScreen = road.local3DToGlobal(lowerRightPos);

				if (lowerRightPosOnScreen.y > billboardBuffer.height) {
					o['deleted'] = true;
					continue;
				}

				var w = lowerRightPosOnScreen.x - lowerLeftPosOnScreen.x;
				var h = (w/o['roadSpaceSize'].x) * o['roadSpaceSize'].y;//lowerRightPosOnScreen.y - upperLeftPosOnScreen.y;

				if (o['type'] == 'player') {
//					ballBuffer.fillRect(ballBuffer.rect, 0xffffffff);

					var tmp = new BitmapData(ballFrames.width, ballFrames.width);
					tmp.copyPixels(ballFrames, new Rectangle(0, ballFrames.width * ballFrame, ballFrames.width, ballFrames.width), new Point(0, 0));
					var mat = new Matrix();
					mat.tx = lowerLeftPosOnScreen.x - 30;	
					mat.ty = lowerLeftPosOnScreen.y - h + 155;
					billboardBuffer.draw(tmp, mat);

/*					var p = new Point(lowerLeftPosOnScreen.x - 30, lowerLeftPosOnScreen.y - h + 155);
					billboardBuffer.copyPixels(ballFrames, new Rectangle(0, ballFrames.width * ballFrame, ballFrames.width, ballFrames.width), p);
*/

//					ball.x = (lowerLeftPosOnScreen.x + lowerRightPosOnScreen.x)/2;
//					ball.y = lowerLeftPosOnScreen.y;
				} else {
					if (o['type'] != 'city') {
						billboardBuffer.fillRect(
							new Rectangle(lowerLeftPosOnScreen.x, lowerLeftPosOnScreen.y - h, w, h),
							o['color']
						);			
					}
				}

				if (o['type'] == 'city') {
					timeleftLabelTxt.visible = false;
					distanceTxt.visible = false;
					timeleftTxt.visible = false;
					win.visible = true;

					w = lowerRightPosOnScreen.x - lowerLeftPosOnScreen.x;
					h = (w/o['roadSpaceSize'].x) * o['roadSpaceSize'].y;

					win.visible = true;
					win.x = lowerLeftPosOnScreen.x;
					win.y = lowerLeftPosOnScreen.y - h;
					win.width = w;
					win.height = h;

					if (win.y > 100) {
						speedRoadPixelsPerSecond = 0;
						targetSpeedRoadPixelsPerSecond = 0;
						win.city.gotoAndPlay(0);
						(new Win()).play();
					}

/*					win.y = 0;
					win.width = w;
					win.height = h;*/
					/*
					win.x = lowerLeftPosOnScreen.x;
					win.y = lowerLeftPosOnScreen.y;
					win.height = w;
					win.width = h;
					if (win.y > 370) {
						speedRoadPixelsPerSecond = 0;
						win.city.gotoAndPlay(0);
					}*/
				}
			}
		}

		function addObstacle(obstacle) {
			for (var i = 0; i < obstacles.length; i++) {
				if (obstacles[i]['deleted']) {
					obstacles[i] = obstacle;
					return;
				}
			}
			obstacles.push(obstacle);
		}

		function deleteNonPlayerObstacles() {
			for (var i = 0; i < obstacles.length; i++) {
				if (obstacles[i]['type'] != 'player') {
					obstacles[i]['deleted'] = true;
				}
			}
		}

		function setNewCheckpointPos() {
			pixelsUntilCheckpoint = levels[checkpointI]['distance'] - player['roadSpacePosition'].y;
			checkpointI++;
			return;
		}

		function setNewCheckpointTimeleft() {
			checkpointCrossedI++;
			curlevelTxt.text = levels[checkpointCrossedI]['name'];
			timeleft = levels[checkpointCrossedI]['timebonus'] * 1000;
			combo = 0;
			levels[checkpointCrossedI]['init'](this);
			checkpointTxt.text = "";// + checkpointCrossedI;
		}

		function spawnObstacles() {
			var type, color, sound, roadSpaceSize, roadSpacePosition;
			levels[checkpointCrossedI]['tick'](this);

			if (pixelsUntilCheckpoint <= 0) {
				setNewCheckpointPos();
				type = 'checkpoint';
				sound = new Checkpoint();
				color = 0xff0000ff;
				roadSpaceSize = new Point(roadBitmapData.width, 10);
				roadSpacePosition = new Vector3D(roadBitmapData.width / 2, 0, 0);
				addObstacle({
					'roadSpacePosition' : roadSpacePosition,
					'roadSpaceSize' : roadSpaceSize,
					'type' : type,
					'color' : color,
					'sound' : sound
				});
			}
		}

/*		var ballSizeX = 0;
		var ballSizeY = 0;
		var desiredBallSize = 0.2;
*/
/*		function expand() {
			desiredBallSize *= 1.5;
		}
*/
		var ballPositionInRoadSpace = new Point(500, 495);
		var ballFrame = 0;
		function advanceBall() {
/*			ballSizeX = desiredBallSize * 0.1 + ballSizeX * 0.9;
			ballSizeY = desiredBallSize * 0.1 + ballSizeY * 0.9;

			ballBuffer.fillRect(ballBuffer.rect, 0xffffffff);
			ballBuffer.copyPixels(ballFrames, new Rectangle(0, ballFrames.width * ballFrame, ballFrames.width, ballFrames.width), new Point(0,0));*/
			ballFrame++;
			if (ballFrame == 30) {
				ballFrame = 0;
			}

/*			ball.scaleX = ballSizeX;
			ballShadow.scaleX = ballSizeX * 1.2;
			ball.scaleY = ballSizeY;
			ballShadow.scaleY = ballSizeY * 1.2;

			var v = road.local3DToGlobal(new Vector3D(ballPositionInRoadSpace.x, ballPositionInRoadSpace.y, 0))
			ball.x = v.x - 120;
			ball.y = v.y - ball.height;

			ballShadow.x = ball.x - 15 * ballShadow.scaleX;
			ballShadow.y = ball.y - 15 * ballShadow.scaleY;
			ballShadow.alpha = 0.5;
			headlights.x = ballPositionInRoadSpace.x - headlights.width/2 + 15 * ballSizeX - 14;
*/
		}

		function controls() {
			if (keys[39] || keys[68]) {
				xs += controlStrength;
			}
			if (keys[37] || keys[65]) {
				xs -= controlStrength;
			}
			xs *= drag;
			if (Math.abs(xs) < 0.1) xs = 0;

			player['roadSpacePosition'].x += xs;
			if (player['roadSpacePosition'].x < 470) {
				xs = 0;
				player['roadSpacePosition'].x = 470;
//				xs += 1;;
			}
			if (player['roadSpacePosition'].x > 560) {
				xs = 0;
				player['roadSpacePosition'].x = 560;
//				xs -= 1;
			}
//			ballPositionInRoadSpace.x += xs;
		}

		function collisionWith(obstacle) {
			obstacle['deleted'] = true;
			if (obstacle['type'] == 'speedup') {
				targetSpeedRoadPixelsPerSecond = 80;
				combo++;
				speedRoadPixelsPerSecond = 150 + combo * 100;
//				if (combo == 2) (new Combo2()).play();
				if (combo == 3) (new Combo3()).play();
//				if (combo == 4) (new Combo4()).play();
//				if (combo == 5) (new Combo5()).play();
//				if (combo == 6) (new Combo6()).play();
//				if (combo > 6) (new Combo7()).play();
			}
			if (obstacle['type'] == 'slowdown') {
				targetSpeedRoadPixelsPerSecond = 80;
				speedRoadPixelsPerSecond = 0;
				combo = 0;
			}
			if (obstacle['sound']) {
				obstacle['sound'].play();
			}
			if (obstacle['type'] == 'checkpoint') {
				setNewCheckpointTimeleft();
				pipipi.play();
			}
		}

		function intersections(pixelsMoved) {
			var playerRect = null;
			for (var i = 0; i < obstacles.length; i++) {
				var o = obstacles[i];
				if (o['deleted']) continue;
				if (o['type'] == 'player') {
					playerRect = new Rectangle(o['roadSpacePosition'].x - o['roadSpaceSize'].x/2, o['roadSpacePosition'].y, o['roadSpaceSize'].x, 2);
				}
			}
			if (playerRect == null) {
				trace('player not found');
				return;
			}

			for (i = 0; i < obstacles.length; i++) {
				o = obstacles[i];
				if (o['deleted']) continue;
				if (o['type'] == 'player') continue;
				var obstacleRect = new Rectangle(o['roadSpacePosition'].x - o['roadSpaceSize'].x/2, o['roadSpacePosition'].y, o['roadSpaceSize'].x, pixelsMoved);
				if (obstacleRect.intersects(playerRect)) {
					collisionWith(o);
				}
			}
		}

		function gameover() {
			(new Death()).play();
			addChild(gameoverScreen);
		}

		function distanceToCheckpoint() {

			// If checkpoint is visible then it is distance to that
			for (var i = 0; i < obstacles.length; i++) {
				if (obstacles[i]['deleted']) continue;
				if (obstacles[i]['type'] != 'checkpoint') continue;
				return player['roadSpacePosition'].y - obstacles[i]['roadSpacePosition'].y;
			}

			return pixelsUntilCheckpoint + player['roadSpacePosition'].y;
		}

		function refresh(evt) {
			var elapsed = getTimer() - lastRefreshStart;

			if (timeleft <= 0) {
				gameoverScreen.y *= 0.80;
				if (Math.abs(gameoverScreen.y) < 10 && gameoverScreen.y != 0) {
					gameoverScreen.y = 0;
					gameoverScreen.addEventListener(MouseEvent.MOUSE_DOWN, function (e) {
						//removeEventListener(gameoverScreen, MouseEvent.MOUSE_DOWN);
						restart();
					});
				}
				if (!didGameover) {
					didGameover = true;
					gameover();
				}
				return;
			} else {
				timeleft -= elapsed;
				if (timeleft < 0) timeleft = 0;
				timeleftTxt.text = "" + (timeleft/1000).toFixed(1);
			}

			if (!inited) {
				initVars();
				init();
				inited = true;
			}

			speedRoadPixelsPerSecond = 0.03 * targetSpeedRoadPixelsPerSecond + 0.97 * speedRoadPixelsPerSecond;
//			trace(headlights.x);
//			headlights.x = headlights.width - roadBitmapData.width/2;
			headlights.x = -(headlights.width - roadBitmapData.width)/2 + player['roadSpacePosition'].x - 512;
			controls();

			lastRefreshStart = getTimer();
			var pixelsMoved = Math.ceil((elapsed/1000.0) * speedRoadPixelsPerSecond);

			advanceRoad(pixelsMoved);

			advanceObstacles(pixelsMoved);
			intersections(pixelsMoved);

			advanceBall();
			billboards();

			pixelsUntilCheckpoint -= pixelsMoved;
			distanceTxt.y = 10;
			distanceTxt.text = "";// + distanceToCheckpoint();
			spawnObstacles();

			totalPixelsTraveled += pixelsMoved;
			totalTimeSpent += elapsed;
		}

		public function Game() {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e) {
//				if (e.keyCode == 32) expand();
				keys[e.keyCode] = true;
			});
			stage.addEventListener(KeyboardEvent.KEY_UP, function (e) {
				keys[e.keyCode] = false;
			});
			addEventListener(Event.ENTER_FRAME, refresh);
		}
	}
}