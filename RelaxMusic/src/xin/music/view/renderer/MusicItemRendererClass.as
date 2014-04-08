package xin.music.view.renderer
{
	import flash.events.ContextMenuEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	import spark.components.DataGroup;
	import spark.components.Image;
	import spark.components.List;
	import spark.components.supportClasses.ItemRenderer;

	import xin.music.model.Model;
	import xin.music.model.ModelLocator;

	public class MusicItemRendererClass extends ItemRenderer
	{
		private var ml:ModelLocator = ModelLocator.getInstance();
		private var m:Model = ml.model;

		public var musicImage:Image;

		[Bindable]
		public var musicName:String;

		[Bindable]
		public var musicSize:String;

		private var music:File;

		public function MusicItemRendererClass()
		{
			super();
			var rightMenu:ContextMenu = new ContextMenu();
			var delMenu:ContextMenuItem = new ContextMenuItem("从列表中删除");
			delMenu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, delMenuSelectHandler);
			var delMenu2:ContextMenuItem = new ContextMenuItem("从文件中删除");
			delMenu2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, delMenu2SelectHandler);
			rightMenu.customItems.push(delMenu);
			rightMenu.customItems.push(delMenu2);
			this.contextMenu = rightMenu;
		}

		override public function set data(value:Object):void
		{
			super.data = value;
			if(!value)
			{
				return;
			}
			if(!m.control.stoped && itemIndex == m.control.playIndex && m.control.playing)
			{
				musicImage.source = m.images.play_green;
			}
			else
			{
				musicImage.source = m.images.music_green;
			}
			musicName = value.name;
			musicName = musicName.substring(0, musicName.lastIndexOf("."));
			musicSize = (Number(value.size) / 1024 / 1024).toFixed(2) + "M";
			music = value as File;
		}

		protected function musicitemrendererclass1_doubleClickHandler(event:MouseEvent):void
		{
			m.control.playIndex = itemIndex;
			m.control.play();
		}

		private function delMenuSelectHandler(event:ContextMenuEvent):void
		{
			if(!m.control.stoped && itemIndex == m.control.playIndex)
			{
				m.control.stop();
			}
			m.musicList.removeItemAt(itemIndex);
		}

		private function delMenu2SelectHandler(event:ContextMenuEvent):void
		{
			if(!m.control.stoped && itemIndex == m.control.playIndex)
			{
				m.control.stop();
			}
			m.musicList.removeItemAt(itemIndex);
			music.deleteFile();
		}
	}
}
