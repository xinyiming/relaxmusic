package xin.music.view
{
	import flash.events.Event;

	import mx.core.IMXMLObject;

	public class ViewHelper implements IMXMLObject
	{
		public var view:Object;

		public var id:String;

		public function initialized(document:Object, id:String):void
		{
			this.view = document;
			this.id = id;

			view.addEventListener(Event.ADDED, registerView);
			view.addEventListener(Event.REMOVED, unregisterView);
		}

		private function registerView(event:Event):void
		{
			if(event.target == view)
			{
				ViewLocator.getInstance().register(id, this);
			}
		}

		private function unregisterView(event:Event):void
		{
			if(event.target == view)
			{
				ViewLocator.getInstance().unregister(id);
			}
		}
	}
}

