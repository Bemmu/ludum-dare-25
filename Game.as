/*
montage 0001.png 0002.png 0003.png 0004.png 0005.png 0006.png 0007.png 0008.png 0009.png 0010.png 0011.png 0012.png 0013.png 0014.png 0015.png 0016.png 0017.png 0018.png 0019.png 0020.png 0021.png 0022.png 0023.png 0024.png 0025.png 0026.png 0027.png 0028.png 0029.png 0030.png 0031.png 0032.png 0033.png 0034.png 0035.png -tile 1x -geometry 230x -background Transparent goo.png
*/

package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;

	public class Game extends Sprite {
		var roadBitmapData;
		var headlights;
		var ball;
		var ballFrames;
		var ballBuffer;
		var ballShadow;

		function drawRoad() {
			var h = 10;

			var grassNoise = new BitmapData(roadBitmapData.width, h);
			grassNoise.noise(getTimer(), 40, 255, BitmapDataChannel.GREEN);
			roadBitmapData.copyPixels(grassNoise, grassNoise.rect, new Point(0, 0));

			var roadX = Math.sin(getTimer()/100.0)*2 + Math.cos(getTimer()/500.0) * 40;
			var roadWidth = 100;
			var someNoise = new BitmapData(roadWidth, h);
			someNoise.noise(getTimer(), 240, 255, BitmapDataChannel.ALPHA);

			roadBitmapData.copyPixels(someNoise, someNoise.rect, new Point(roadBitmapData.width/2 + roadX - roadWidth/2, 0));
		}

		function advanceRoad(pixels) {
			var roadX = 0;
			var roadWidth = 100;
			var h = pixels;
			var grassNoise = new BitmapData(roadBitmapData.width, h);
			grassNoise.noise(getTimer(), 40, 255, BitmapDataChannel.GREEN);
			roadBitmapData.copyPixels(grassNoise, grassNoise.rect, new Point(0, 0));

			var asphaltBitmap = new BitmapData(roadWidth, h);
			asphaltBitmap.noise(getTimer(), 0, 50, 0x17, true);
			roadBitmapData.copyPixels(asphaltBitmap, asphaltBitmap.rect, new Point(roadBitmapData.width/2 + roadX - roadWidth/2, 0));

			var roadBorder = 5;
			var sidelineBitmap = new BitmapData(roadBorder, h, true);
			sidelineBitmap.noise(getTimer(), 100, 255, BitmapDataChannel.ALPHA, true);
			roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(roadBitmapData.width/2 + roadX - roadWidth/2, 0));
			roadBitmapData.copyPixels(sidelineBitmap, sidelineBitmap.rect, new Point(roadBitmapData.width/2 + roadX + roadWidth/2 - roadBorder, 0));

			// Advance the road
			roadBitmapData.copyPixels(roadBitmapData, roadBitmapData.rect, new Point(0, h));
		}

		var inited = false;
		var lastRefreshStart;
		var speedRoadPixelsPerSecond = 40;

		function init() {
			advanceRoad(roadBitmapData.height);
		}

		var keys = {};

		function billboards() {
			var billboardX = mouseX;//mouseX;//roadBitmapData.width / 2;
			var billboardY = mouseY;//roadBitmapData.height / 2;
			var billboardZ = 0;

			var result = road.local3DToGlobal(new Vector3D(billboardX, billboardY, billboardZ));

//			marker.x = result.x;
//			marker.y = result.y;
		}

		var ballSizeX = 0;
		var ballSizeY = 0;
		var desiredBallSize = 0.2;

		function expand() {
			desiredBallSize *= 1.5;
		}

		var ballPositionInRoadSpace = new Point(500, 495);
		var ballFrame = 0;
		function advanceBall() {
			ballSizeX = desiredBallSize * 0.1 + ballSizeX * 0.9;
			ballSizeY = desiredBallSize * 0.1 + ballSizeY * 0.9;

			ballBuffer.fillRect(ballBuffer.rect, 0xffffffff);
			ballBuffer.copyPixels(ballFrames, new Rectangle(0, ballFrames.width * ballFrame, ballFrames.width, ballFrames.width), new Point(0,0));
			ballFrame++;
			if (ballFrame == 30) {
				ballFrame = 0;
			}

			ball.scaleX = ballSizeX;
			ballShadow.scaleX = ballSizeX * 1.2;
			ball.scaleY = ballSizeY;
			ballShadow.scaleY = ballSizeY * 1.2;

			var v = road.local3DToGlobal(new Vector3D(ballPositionInRoadSpace.x, ballPositionInRoadSpace.y, 0))
			ball.x = v.x - 120;
			ball.y = v.y - 160;

			ballShadow.x = ball.x - 15 * ballShadow.scaleX;
			ballShadow.y = ball.y - 15 * ballShadow.scaleY;
			ballShadow.alpha = 0.5;
			headlights.x = ballPositionInRoadSpace.x - headlights.width/2 + 15 * ballSizeX - 14;

		}

		var xs = 0;
		function controls() {
			if (keys[39]) {
				xs += 1;
			}
			if (keys[37]) {
				xs -= 1;
			}
			xs *= 0.85;
			if (Math.abs(xs) < 0.5) xs = 0;
			ballPositionInRoadSpace.x += xs;
		}

		function refresh(evt) {
			if (!inited) {
				init();
				inited = true;
			}

			controls();
			var elapsed = getTimer() - lastRefreshStart;
			lastRefreshStart = getTimer();
			var pixelsMoved = Math.ceil((elapsed/1000.0) * speedRoadPixelsPerSecond);
			advanceRoad(pixelsMoved);
			advanceBall();
			billboards();
		}

		public function Game() {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, function (e) {
				if (e.keyCode == 32) expand();
				keys[e.keyCode] = true;
			});
			stage.addEventListener(KeyboardEvent.KEY_UP, function (e) {
				keys[e.keyCode] = false;
			});

			roadBitmapData = new BitmapData(road.width, road.height, false);
			road.addChild(new Bitmap(roadBitmapData));

			headlights = new Bitmap(new Headlights());
			headlights.width = roadBitmapData.width * 2;
			headlights.height = roadBitmapData.height;
			headlights.x = -(headlights.width - roadBitmapData.width)/2;
			road.addChild(headlights);

			ballFrames = new GooBall();						
			ballBuffer = new BitmapData(230, 230, true, 0);
			ball = new Bitmap(ballBuffer);
			ballShadow = new Bitmap(new Shadow());
			addChild(ballShadow);
			addChild(ball);

			marker.visible = false;

			lastRefreshStart = getTimer();
			addEventListener(Event.ENTER_FRAME, refresh);
		}
	}
}