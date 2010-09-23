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
} DataOperationCodes;

//	
//	Data object keys for node objects and xpaths
//	

#define kOnAirXPath			@"root"
#define kOnAirKey			@"OnAir"
#define kEventsXPath		@"Event"
#define kShowArchivesXPath	@"S"
#define kShowIDKey			@"ShowID"