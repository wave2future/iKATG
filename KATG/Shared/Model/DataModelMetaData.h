//
//  DataModelMetaData.h
//  

#import <Foundation/Foundation.h>

//	
//	API URIs
//	

static NSString * const kLiveShowStatusAddress	=	@"/Api/App/Feed/Live/json";

static NSString * const kFeedbackBaseURLAddress	=	@"http://www.attackwork.com";
static NSString * const kFeedbackURIAddress		=	@"/Voxback/Comment-Form-Iframe.aspx";

static NSString * const kEventsFeedAddress		=	@"/Api/App/Events/json/";

static NSString * const kShowListURIAddress		=	@"/Api/App/ShowArchive/ListCompact/json/";
static NSString * const kShowDetailsURIAddress	=	@"/Api/App/ShowArchive/Show/Details/json/";
static NSString * const kShowPicturesURIAddress	=	@"/Api/App/ShowArchive/Show/Pictures/json/";

static NSString * const kTwitterSearchFeedBaseURLAddress		=	@"http://search.twitter.com";
static NSString * const kTwitterSearchFeedURIAddress			=	@"/search.json?q=from%3Achemda+OR+from%3Akeithandthegirl+OR+from%3AKeithMalley&rpp=50";
static NSString * const kTwitterSearchExtendedFeedURIAddress	=	@"/search.json?q=from%3Achemda+OR+from%3Akeithandthegirl+OR+from%3AKeithMalley+OR+from%3AKaTGShowAlert+OR+%3Akeithmalley+OR+%3Achemda+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22&rpp=50";
static NSString * const kTwitterBaseURLAddress					=	@"http://twitter.com";
static NSString * const kTwitterUserURIAddress					=	@"/statuses/user_timeline/";

static NSString * const kLinksListURIAddress	=	@"/Api/App/Links.json";

//static NSString * const kChatLoginBaseURLAddress=	@"http://www.keithandthegirl.com";
//static NSString * const kChatLoginURIAddress	=	@"/Chat/Chat-Login.aspx";

//	
//	Data operation codes
//	

typedef enum {
	//	Live Show Feed Status
	kLiveShowStatusCode,
	//	Next Live Show Time & Guests
	kNextLiveShowCode,
	//	Live Show Feed Back
	kFeedbackCode,
	// Chat
	kChatCode,
	//	Events List
	kEventsListCode,
	//	Archive Shows List And Details
	kShowArchivesCode,
	kShowDetailsCode,
	kShowPicturesCode,
	kGetImageCode,
	//	Twitter
	kTwitterSearchCode,
	kTwitterUserFeedCode,
	kTwitterHashTagCode,
	kGetTwitterImageCode,
} DataOperationCodes;

typedef enum {
	kEventsAvailable,
	kEventsWaitingOnCache,
	kEventsWaitingOnWeb,
	kEventsUnavailable
} EventsAvailability;

//	
//	Data object keys for node objects and xpaths
//	

#define kOnAirKey			@"OnAir"
#define kEventsXPath		@"Event"
#define kShowArchivesXPath	@"S"
#define kShowIDKey			@"ShowID"
#define kShowDetailsXPath	@"root"
#define kShowPicturesXPath	@"picture"
//	
//	Twitter Keys
//	
#define	kFromUserKey			@"from_user"
#define	kProfileImageKey		@"profile_image_url"
#define	kTextKey				@"text"
#define	kDateKey				@"created_at"

//	
//	Logging
//	

#define LogEventCaching 0

//	
//	Testing
//	

#define TestErrorEventHandling 0