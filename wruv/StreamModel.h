//
//  StreamModel.h
//
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import <UIKit/UIKit.h>
#import <CFNetwork/CFNetwork.h>

#define bufferSize 16
#define MaxPacketDescs 512
#define DefaultBufSize 2048

@interface StreamModel : NSObject

{
    
    NSURL *url;
    CFReadStreamRef stream; //My Stream var for CFStream methods
    AudioFileStreamID audioFileStream; //Parses the Audio File Stream
    OSStatus audioSessionMaster; //Streaming Var
    BOOL seekWasRequested;
    BOOL isRunning;
    BOOL notStopping;
    NSInteger buffersUsed;
    NSDictionary *httpHeaders;
    AudioStreamBasicDescription asbd;
    AudioQueueRef audioQueue;
    AudioQueueBufferRef audioQueueBuffer[bufferSize];
    AudioStreamPacketDescription packetDescs[MaxPacketDescs]; //packet descriptions for enqueing audio
    size_t packetsFilled; //used in handleAudioPackets method 
    size_t bytesFilled;  //I think some of my methods need this to be a size_t rather than a double
    UInt32 packetBufferSize;
    unsigned int fillBufferIndex;
    bool inuse[bufferSize];
    UIBackgroundTaskIdentifier bgTaskId;
    pthread_mutex_t queueBuffersMutex;			// a mutex to protect the inuse flags
	pthread_cond_t queueBufferReadyCondition;	// a condition varable for handling the inuse flags
    

}

@property (nonatomic, retain) NSURL *url;
@property (readonly) NSDictionary *httpHeaders;
    
- (id)initWithURL:(NSURL *)aURL;
- (BOOL)openStream;
- (void)stop;
- (void)start;
- (void)createQueue;
- (void)enqueueBuffer;
//- (void) cleanUpStream;
- (void)handleReadFromStream:(CFReadStreamRef)aStream;
- (void)handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream
                     fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID;
- (void)handleAudioPackets:(const void *)inInputData
             numberPackets:(UInt32)inNumberPackets
        packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions;
- (void)handleBufferCompleteForQueue:(AudioQueueRef)inAQ
                              buffer:(AudioQueueBufferRef)inBuffer;
- (void)handlePropertyChangeForQueue:(AudioQueueRef)inAQ
                          propertyID:(AudioQueuePropertyID)inID;
//I think this needs to be a regular C method because of the way it's called by low level functions
void ASReadStreamCallBack
(
 CFReadStreamRef aStream,
 CFStreamEventType eventType,
 void* inClientInfo
 );
void MyPropertyListenerProc(	void *							inClientData,
                            AudioFileStreamID				inAudioFileStream,
                            AudioFileStreamPropertyID		inPropertyID,
                            UInt32 *						ioFlags);
void MyPacketsProc(				void *							inClientData,
                   UInt32							inNumberBytes,
                   UInt32							inNumberPackets,
                   const void *					inInputData,
                   AudioStreamPacketDescription	*inPacketDescriptions);
void MyAudioQueueOutputCallback(	void*					inClientData, 
                                AudioQueueRef			inAQ, 
                                AudioQueueBufferRef		inBuffer);
void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID);

@end
