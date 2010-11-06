//
//  DataModelMetaData.h
//  

#import <Foundation/Foundation.h>

//	
//	API URIs
//	

static NSString * const kLiveShowStatusAddress	=	@"/Api/App/Feed/Live/";

static NSString * const kFeedbackBaseURLAddress	=	@"http://www.attackwork.com";
static NSString * const kFeedbackURIAddress		=	@"/Voxback/Comment-Form-Iframe.aspx";

static NSString * const kChatLoginBaseURLAddress=	@"http://www.keithandthegirl.com";
static NSString * const kChatLoginURIAddress	=	@"/Chat/Chat-Login.aspx";

static NSString * const kChatStartBaseURLAddress=	@"http://www.keithandthegirl.com";
static NSString * const kChatStartURIAddress	=	@"/Chat/Chatroom.aspx";

static NSString * const kEventsFeedAddress		=	@"/Api/App/Events/";

static NSString * const kShowListURIAddress		=	@"/Api/App/ShowArchive/ListCompact/";
static NSString * const kShowDetailsURIAddress	=	@"/Api/App/ShowArchive/Show/Details/";
static NSString * const kShowPicturesURIAddress	=	@"/Api/App/ShowArchive/Show/Pictures/";

static NSString * const kTwitterSearchFeedBaseURLAddress		=	@"http://search.twitter.com";
static NSString * const kTwitterSearchFeedURIAddress			=	@"/search.json?q=from%3Achemda+OR+from%3Akeithandthegirl+OR+from%3AKeithMalley&rpp=50";
static NSString * const kTwitterSearchExtendedFeedURIAddress	=	@"/search.json?q=from%3Achemda+OR+from%3Akeithandthegirl+OR+from%3AKeithMalley+OR+from%3AKaTGShowAlert+OR+%3Akeithmalley+OR+%3Achemda+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22&rpp=50";
static NSString * const kTwitterBaseURLAddress					=	@"http://twitter.com";
static NSString * const kTwitterUserURIAddress					=	@"/statuses/user_timeline/";

static NSString * const kLinksListURIAddress	=	@"/Api/App/Links.xml";

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
	//	
	kChatLoginPhaseOneCode,
	kChatLoginPhaseTwoCode,
	kChatStartCodePhaseOne,
	kChatStartCodePhaseTwo,
	kChatPollingCode,
	//	Events List
	kEventsListCode,
	//	Archive Shows List And Details
	kShowArchivesCode,
	kShowDetailsCode,
	kShowPicturesCode,
	//	Twitter
	kTwitterSearchCode,
	kTwitterUserFeedCode,
	kTwitterHashTagCode,
	kGetTwitterImageCode,
} DataOperationCodes;

//	
//	Data object keys for node objects and xpaths
//	

#define kOnAirXPath			@"root"
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