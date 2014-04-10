package xin.music.control
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	import mx.collections.XMLListCollection;

	import spark.components.DataGroup;

	import xin.music.model.Model;
	import xin.music.model.ModelLocator;
	import xin.music.view.MusicPlayer;
	import xin.music.view.ViewHelper;
	import xin.music.view.ViewLocator;
	import xin.music.view.renderer.MusicItemRenderer;

	public class Control
	{
		private var ml:ModelLocator = ModelLocator.getInstance();
		private var m:Model = ml.model;
		private var vl:ViewLocator = ViewLocator.getInstance();
		private var musicPlayer:MusicPlayer;

		private var _playing:Boolean = false;
		private var _stoped:Boolean = true;
		public var sound:Sound;
		public var channel:SoundChannel;
		public var playIndex:int = 0;
		private var pausePosition:Number = 0;
		private var transform:SoundTransform = new SoundTransform();

		public var randomPlay:Boolean = false;
		public var loopPlay:Boolean = false;

		public function Control()
		{
		}

		public function init():void
		{
			var musicPlayerVH:ViewHelper = vl.getViewHelper("musicPlayer");
			if(musicPlayerVH != null)
			{
				musicPlayer = musicPlayerVH.view as MusicPlayer;
			}

			var musicDir:File = File.documentsDirectory.resolvePath("RelaxMusic/musicDir.xml");
			if(musicDir.exists)
			{
				var openStream:FileStream = new FileStream();
				openStream.open(musicDir, FileMode.READ);
				var data:XML = new XML(openStream.readUTFBytes(openStream.bytesAvailable));
				var xmlList:XMLListCollection = new XMLListCollection(data.musicDir);
				for each(var dir:String in xmlList)
				{
					findMusic(new File(dir));
				}
			}
		}

		private function findMusic(file:File):void
		{
			if(file.isDirectory)
			{
				var musics:Array = file.getDirectoryListing();
				for(var i:int = 0; i < musics.length; i++)
				{
					findMusic(musics[i] as File);
				}
			}
			else
			{
				if(file.extension == "mp3")
				{
					m.musicList.addItem(file);
				}
			}
		}

		public function get playing():Boolean
		{
			return _playing;
		}

		public function set playing(value:Boolean):void
		{
			_playing = value;
			if(value)
			{
				musicPlayer.playBtn.source = m.images.pauseImage;
			}
			else
			{
				musicPlayer.playBtn.source = m.images.playImage;
			}
		}

		public function get stoped():Boolean
		{
			return _stoped;
		}

		public function set stoped(value:Boolean):void
		{
			_stoped = value;
			if(value)
			{
				musicPlayer.stopBtn.source = m.images.stopImage;
			}
			else
			{
				musicPlayer.stopBtn.source = m.images.stopImage2;
			}
		}

		/**
		 * 播放/暂停
		 */
		public function playMusic():void
		{
			if(!playing)
			{
				if(!channel)
				{
					play();
				}
				else
				{
					resume();
				}
			}
			else
			{
				pause();
			}
		}

		public function play():void
		{
			stop();
			sound = new Sound();
			sound.addEventListener(Event.COMPLETE, onLoadComplete);
			sound.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			sound.addEventListener(Event.ID3, onLoadID3);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			sound.load(new URLRequest(m.musicList[playIndex].url));

			channel = sound.play(0);
			channel.soundTransform = transform;
			channel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
			playing = true;
			stoped = false;

			musicPlayer.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			musicPlayer.songList.ensureIndexIsVisible(playIndex);
			musicPlayer.songList.selectedIndex = playIndex;

			notification();
		}

		public function pause():void
		{
			musicPlayer.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			pausePosition = channel.position;
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
			playing = false;

			var musicItemRenderer:MusicItemRenderer = musicPlayer.songList.dataGroup.getElementAt(playIndex) as MusicItemRenderer;
			if(musicItemRenderer)
			{
				musicItemRenderer.musicImage.source = m.images.pause_green;
			}
		}

		public function seek(postion:Number):void
		{
			if(!stoped && sound && channel)
			{
				pause();

				channel = sound.play(postion);
				channel.soundTransform = transform;
				channel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
				playing = true;
				musicPlayer.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}

		private function resume():void
		{
			channel = sound.play(pausePosition);
			channel.soundTransform = transform;
			channel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
			playing = true;
			musicPlayer.addEventListener(Event.ENTER_FRAME, onEnterFrame);

			var musicItemRenderer:MusicItemRenderer = musicPlayer.songList.dataGroup.getElementAt(playIndex) as MusicItemRenderer;
			if(musicItemRenderer)
			{
				musicItemRenderer.musicImage.source = m.images.play_green;
			}
		}

		/**
		 * 跳播
		 */
		private function skipMusic(playIndex:int):void
		{
			if(playIndex >= 0 && playIndex < m.musicList.length)
			{
				play();
			}
		}

		/**
		 * 上一曲
		 */
		public function playPre():void
		{
			if(randomPlay)
			{
				playIndex = int(Math.random() * m.musicList.length);
				skipMusic(playIndex);
			}
			else
			{
				if(playIndex > 0)
				{
					skipMusic(--playIndex);
				}
				else
				{
					playIndex = m.musicList.length - 1;
					skipMusic(playIndex);
				}
			}
		}

		/**
		 * 下一曲
		 */
		public function playNext():void
		{
			if(randomPlay)
			{
				playIndex = int(Math.random() * m.musicList.length);
				skipMusic(playIndex);
			}
			else
			{
				if(playIndex < m.musicList.length - 1)
				{
					skipMusic(++playIndex);
				}
				else
				{
					playIndex = 0;
					skipMusic(playIndex);
				}
			}
		}

		/**
		 * 停止播放音乐
		 */
		public function stop():void
		{
			musicPlayer.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			playing = false;
			stoped = true;
			pausePosition = 0;
			try
			{
				if(channel)
				{
					channel.stop();
					channel.removeEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
					channel = null;
				}

				var musicItemRenderer:MusicItemRenderer = musicPlayer.songList.dataGroup.getElementAt(playIndex) as MusicItemRenderer;
				if(musicItemRenderer)
				{
					musicItemRenderer.musicImage.source = m.images.music_green;
				}

				if(sound)
				{
					sound.removeEventListener(Event.COMPLETE, onLoadComplete);
					sound.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
					sound.removeEventListener(Event.ID3, onLoadID3);
					sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					if(sound.isBuffering)
					{
						sound.close();
					}
					sound = null;
				}
			}
			catch(error:IOError)
			{
				trace(error.message);
			}
		}

		/**
		 * 把毫秒值格式化为00:00
		 */
		public function formatTime(time:Number):String
		{
			if(time <= 0)
			{
				return "00:00";
			}
			var result:String = "";
			time /= 1000;
			if(time < 60)
			{
				if(time < 10)
				{
					result = "00:0" + int(time);
				}
				else
				{
					result = "00:" + int(time);
				}
			}
			else
			{
				var second:Number = time % 60;
				var minute:Number = time / 60;
				if(minute < 10)
				{
					result = "0" + int(minute) + ":";
				}
				else
				{
					result = int(minute) + ":";
				}
				if(second < 10)
				{
					result += "0" + int(second);
				}
				else
				{
					result += int(second);
				}
			}
			return result;
		}

		private function onLoadComplete(event:Event):void
		{
			//			trace("歌曲时间 : " + formatTime(sound.length));
			//			trace("歌曲大小 : " + formatSize(sound.bytesTotal));
		}

		public function onPlaybackComplete(event:Event):void
		{
			//			trace("The sound has finished playing.");
			if(loopPlay)
			{
				play();
			}
			else
			{
				playNext();
			}
		}

		private function onEnterFrame(event:Event):void
		{
			var estimatedLength:int = Math.ceil(sound.length / (sound.bytesLoaded / sound.bytesTotal));
			musicPlayer.slider.maximum = estimatedLength;
			musicPlayer.musicLength = formatTime(estimatedLength);
			musicPlayer.playbackPosition = formatTime(channel.position);
			musicPlayer.slider.value = channel.position;
			musicPlayer.soundSlider.value = channel.soundTransform.volume;
		}

		private function onLoadProgress(event:ProgressEvent):void
		{
			//			var loadedPct:uint = Math.round(100 * (event.bytesLoaded / event.bytesTotal));
			//			trace("The sound is " + loadedPct + "% loaded.");
		}

		private function onLoadID3(event:Event):void
		{
			musicPlayer.songName = sound.id3.songName;
			musicPlayer.songAlbum = (sound.id3.artist == null ? "未知歌手" : sound.id3.artist) + " - " + (sound.id3.album == null ? "未知专辑" : sound.id3.album);

		}

		private function onIOError(event:IOErrorEvent):void
		{
			trace(event.text);
		}

		public function openDir():void
		{
			var openDir:File = new File();
			openDir.addEventListener(Event.SELECT, dirSelectHandler);
			openDir.browseForDirectory("选择您的歌曲文件夹 ^_^");
		}

		private function dirSelectHandler(event:Event):void
		{
			var musicDir:File = File.documentsDirectory.resolvePath("RelaxMusic/musicDir.xml");
			var openStream:FileStream = new FileStream();
//			if(musicDir.exists)
//			{
//				openStream.open(musicDir, FileMode.READ);
//				var data:XML = new XML(openStream.readUTFBytes(openStream.bytesAvailable));
//				data.appendChild(<musicDir>{(event.target as File).url}</musicDir>);
//				
//				openStream.open(musicDir, FileMode.WRITE);
//				openStream.writeUTFBytes(data.toXMLString());
//				openStream.close();
//			}
//			else
//			{
			openStream.open(musicDir, FileMode.WRITE);
			var xml:XML = <root><musicDir>{(event.target as File).url}</musicDir></root>;
			openStream.writeUTFBytes(xml.toXMLString());
			openStream.close();
//			}
			findMusic(event.target as File);
		}

		public function changeVolume(value:Number):void
		{
			if(channel)
			{
//				musicPlayer.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				transform.volume = value;
				channel.soundTransform = transform;
//				musicPlayer.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}

		private function notification():void
		{
			var dataGroup:DataGroup = musicPlayer.songList.dataGroup;
			var musicItemRenderer:MusicItemRenderer;
			for(var i:int = 0; i < dataGroup.numElements; i++)
			{
				musicItemRenderer = dataGroup.getElementAt(i) as MusicItemRenderer;
				if(musicItemRenderer)
				{
					if(i == m.control.playIndex)
					{
						musicItemRenderer.musicImage.source = m.images.play_green;
					}
					else
					{
						musicItemRenderer.musicImage.source = m.images.music_green;
					}
				}
			}
		}
	}
}
