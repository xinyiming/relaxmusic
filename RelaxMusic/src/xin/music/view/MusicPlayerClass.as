package xin.music.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.events.FlexEvent;

	import spark.components.CheckBox;
	import spark.components.HSlider;
	import spark.components.Image;
	import spark.components.List;
	import spark.components.SkinnableContainer;

	import xin.music.control.Control;
	import xin.music.model.Model;
	import xin.music.model.ModelLocator;
	import xin.music.view.renderer.MusicItemRenderer;

	public class MusicPlayerClass extends SkinnableContainer
	{

		private var ml:ModelLocator = ModelLocator.getInstance();
		[Bindable]
		public var m:Model = ml.model;

		private var vl:ViewLocator = ViewLocator.getInstance();

		public var control:Control;

		public var playBtn:Image;
		public var stopBtn:Image;
		public var slider:HSlider;
		public var soundSlider:HSlider;
		public var songList:List;
		[Bindable]
		public var songName:String;

		[Bindable]
		public var songAlbum:String;

		[Bindable]
		public var playbackPosition:String = "00:00";

		[Bindable]
		public var musicLength:String = "00:00";

		public function MusicPlayerClass()
		{
			super();
		}

		protected function musicplayerclass1_creationCompleteHandler(event:FlexEvent):void
		{
			var musicPlayerVH:ViewHelper = new ViewHelper();
			musicPlayerVH.id = "musicPlayer";
			musicPlayerVH.view = this;
			vl.register(musicPlayerVH.id, musicPlayerVH);

			m.control = control;
			control.init();
		}

		protected function preBtn_clickHandler(event:MouseEvent):void
		{
			control.playPre();
		}

		protected function playBtn_clickHandler(event:MouseEvent):void
		{
			control.playMusic();
		}

		protected function nextBtn_clickHandler(event:MouseEvent):void
		{
			control.playNext();
		}

		protected function stopBtn_clickHandler(event:MouseEvent):void
		{
			control.stop();
		}

		protected function openBtn_clickHandler(event:MouseEvent):void
		{
			control.openDir();
		}

		protected function slider_changeHandler(event:Event):void
		{
			control.seek((slider.mouseX / slider.width) * slider.maximum);

			var musicItemRenderer:MusicItemRenderer = songList.dataGroup.getElementAt(control.playIndex) as MusicItemRenderer;
			if(musicItemRenderer)
			{
				musicItemRenderer.musicImage.source = m.images.play_green;
			}
		}

		protected function formatTipFunction(item:Object):String
		{
			return control.formatTime(slider.value);
		}

//		protected function slider_mouseMoveHandler(event:MouseEvent):void
//		{
//			slider.toolTip = null;
//			var point:Number;
//			if(event.target == slider.thumb)
//			{
//				point = slider.value;
//			}
//			else
//			{
//				point = (slider.mouseX / slider.width) * slider.maximum;
//			}
//			slider.toolTip = formatTime(point);
//		}

		protected function formatSoundTipFunction(item:Object):String
		{
			return soundSlider.value * 100 + " %";
		}

		protected function soundSlider_changeHandler(event:Event):void
		{
			control.changeVolume(soundSlider.value);
		}

		protected function randomPlayCB_changeHandler(event:Event):void
		{
			if((event.target as CheckBox).selected)
			{
				control.randomPlay = true;
			}
			else
			{
				control.randomPlay = false;
			}
		}

		protected function loopPlayCB_changeHandler(event:Event):void
		{
			if((event.target as CheckBox).selected)
			{
				control.loopPlay = true;
			}
			else
			{
				control.loopPlay = false;
			}
		}
	}
}
