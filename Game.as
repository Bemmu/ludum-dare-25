package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;

	public class Game extends Sprite {
		var backbufferBitmapData;
		var frontbufferBitmapData;

		var roadBitmapData;

		var past;
		function tick() {
			var now = getTimer();
			var elapsedSeconds = (now - past)*0.001;
			past = now;
		}

		function flip() {
			frontbufferBitmapData.copyPixels(
				backbufferBitmapData,
				new Rectangle(0, 0, backbufferBitmapData.width, backbufferBitmapData.height),
				new Point(0, 0)
			);
		}

		function drawRoad() {
			var h = 10;

			var grassNoise = new BitmapData(roadBitmapData.width, h);
			grassNoise.noise(getTimer(), 40, 255, BitmapDataChannel.GREEN);
			roadBitmapData.copyPixels(grassNoise, grassNoise.rect, new Point(0, 0));
//			roadBitmapData.fillRect(new Rectangle(0, 0, roadBitmapData.width, h), 0xff00ff00);


			var roadX = Math.sin(getTimer()/100.0)*2 + Math.cos(getTimer()/500.0) * 40;
			var roadWidth = 100;
			var someNoise = new BitmapData(roadWidth, h);
			someNoise.noise(getTimer(), 240, 255, BitmapDataChannel.ALPHA);

//			roadBitmapData.fillRect(new Rectangle(roadBitmapData.width/2 + roadX - roadWidth/2, 0, roadWidth, h), 0xffff0000);
			roadBitmapData.copyPixels(someNoise, someNoise.rect, new Point(roadBitmapData.width/2 + roadX - roadWidth/2, 0));
		}

		function render() {
			roadBitmapData.copyPixels(roadBitmapData, roadBitmapData.rect, new Point(0, 9));
		}

		var inited = false;
		function init() {
			trace(road.z);
		}

		function refresh(evt) {
			if (!inited) {
				init();
				inited = true;
			}

			var start = getTimer();		
			drawRoad();
			render();	
/*			render(); 
			var renderTime = getTimer();
			tick();
//			trace(renderTime - start, 'ms / render()', getTimer() - renderTime, 'ms / tick()');
			flip();*/
		}

		public function Game() {
//			road.transform.matrix3D = new Matrix3D(new Vector.<Number>([0.2, 0, 0, 1,  0, 1, 0, 1,  0, 0, 1, 1,  0, 0, 0, 1]));

//			trace(road.transform.matrix3D);
			roadBitmapData = new BitmapData(road.width, road.height);
//			roadBitmapData.fillRect(roadBitmapData.rect, 0xff00ff00);
			road.addChild(new Bitmap(roadBitmapData));
			past = getTimer();
			addEventListener(Event.ENTER_FRAME, refresh);
		}
	}
}