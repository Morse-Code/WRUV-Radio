//
//  StreamModel.m
//
//

#import "StreamModel.h"

@implementation StreamModel
    
static StreamModel *__streamer = nil;
 
@synthesize url, httpHeaders;


#pragma mark CFStream Methods

- (id)initWithURL:(NSURL *)aURL
{
	self = [super init];
	if (self != nil)
	{
		url = aURL;
	}
    NSLog(@"initWithURL");
	return self;
}
//
// ReadStreamCallBack
//
// This is the callback for the CFReadStream from the network connection. This
// is where all network data is passed to the AudioFileStream.
//
// Invoked when an error occurs, the stream ends or we have data to read.
//
void ASReadStreamCallBack
(
 CFReadStreamRef aStream,
 CFStreamEventType eventType,
 void* inClientInfo
 )
{
    NSLog(@"ASReadStreamCallBack");
	StreamModel* __streamer = (__bridge StreamModel*)inClientInfo;
	[__streamer handleReadFromStream:aStream];
}
void MyPropertyListenerProc(	void *							inClientData,
                            AudioFileStreamID				inAudioFileStream,
                            AudioFileStreamPropertyID		inPropertyID,
                            UInt32 *						ioFlags)
{
	NSLog(@"MyPropertyListenerProc");
	// this is called by audio file stream when it finds property values
	StreamModel* __streamer = (__bridge StreamModel*)inClientData;
	[__streamer 
        handlePropertyChangeForFileStream:inAudioFileStream
                     fileStreamPropertyID:inPropertyID];
}
void MyPacketsProc(				void *							inClientData,
                   UInt32							inNumberBytes,
                   UInt32							inNumberPackets,
                   const void *					inInputData,
                   AudioStreamPacketDescription	*inPacketDescriptions)
{
	// this is called by audio file stream when it finds packets of audio
	StreamModel* __streamer = (__bridge StreamModel*)inClientData;
	[__streamer
        handleAudioPackets:inInputData
             numberPackets:inNumberPackets
        packetDescriptions:inPacketDescriptions];
}

// This function is unchanged from Apple's example in AudioFileStreamExample.
//
void MyAudioQueueOutputCallback(	void*					inClientData, 
                                AudioQueueRef			inAQ, 
                                AudioQueueBufferRef		inBuffer)
{
	// this is called by the audio queue when it has finished decoding our data. 
	// The buffer is now free to be reused.
	StreamModel* __streamer = (__bridge StreamModel*)inClientData;
	[__streamer handleBufferCompleteForQueue:inAQ buffer:inBuffer];
}

// Called from the AudioQueue when playback is started or stopped. 
void MyAudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	StreamModel* __streamer = (__bridge StreamModel*)inUserData;
	[__streamer handlePropertyChangeForQueue:inAQ propertyID:inID];
}

- (BOOL)openStream{
    NSLog(@"OpenStream");
    
    // Create the HTTP GET request
    CFHTTPMessageRef getMessage = CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"GET",(__bridge CFURLRef)url, kCFHTTPVersion1_1);
    
    // stream property receives data from the HTTP request
    stream = CFReadStreamCreateForHTTPRequest(NULL, getMessage);

    CFRelease(getMessage);
    
    
    //I really don't know why I need this but it seemed to be imperative on the example
    if (!CFReadStreamOpen(stream))
    {
        CFRelease(stream);
        
        return NO;
    }
    
    //
    // Set our callback function to receive the data
    //
    CFStreamClientContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
    CFReadStreamSetClient(
                          stream,
                          kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered,
                          ASReadStreamCallBack,
                          &context);
    CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    NSLog(@"End of openStream");
    return YES;
}

- (void)stop{
    
    NSLog(@"STOP!");
    //I stop the AudioQueue process before I clear the buffers
    audioSessionMaster = AudioQueueStop(audioQueue, TRUE);
    //Here I'm manually clearing each buffer
    for (int i = 0; i < bufferSize; i++){
        audioSessionMaster = AudioQueueFreeBuffer(audioQueue, audioQueueBuffer[i]);
    }
    notStopping = FALSE;
    //clears all resources, including buffers
    //Passing FALSE makes it so the disposal does not take place until all enqueued buffers are processed
    audioSessionMaster = AudioQueueDispose(audioQueue, FALSE);
    
}
//Initializes an audiosession so we can begin playback
- (void)start{
    NSLog(@"start");
    notStopping = TRUE;
    void MyAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState);
    
    //Initialize AudioSession
    //A method in AudioServices.h needed to start any playback
    AudioSessionInitialize (
                            NULL,
                            NULL,
                            NULL,
                            NULL                      
                            );
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
    AudioSessionSetActive(true);
    __streamer = self;
    
    //allows us to begin
    if (![self openStream])
    {
        AudioSessionSetActive(false);
    }
     
    //continually processes the loop
    isRunning = YES;
    do{
        //NSLog(@"isRunnning BOOL Loop");
        isRunning = [[NSRunLoop currentRunLoop]
                     runMode:NSDefaultRunLoopMode
                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
    } while (isRunning);
    
    
}

- (void)createQueue{
    NSLog(@"CreateQueue");
    
    // create the audio queue (like the method name!)
	audioSessionMaster = AudioQueueNewOutput(&asbd, MyAudioQueueOutputCallback, (__bridge void*)self, NULL, NULL, 0, &audioQueue);
    
    // start the queue if it has not been started already
	// listen to the "isRunning" property
	audioSessionMaster = AudioQueueAddPropertyListener(audioQueue, kAudioQueueProperty_IsRunning, MyAudioQueueIsRunningCallback, (__bridge void*)self);
    
    //WBOR packets are the default size as defined in my header
    packetBufferSize = DefaultBufSize;
    
    // allocate audio queue buffers
	for (unsigned int i = 0; i < bufferSize; ++i)
	{
		audioSessionMaster = AudioQueueAllocateBuffer(audioQueue, packetBufferSize, &audioQueueBuffer[i]);
	}
    
}
//Adds a buffer to the buffer queue of a recording or playback audio queue.
// This function is also adapted from Apple's example in AudioFileStreamExample
- (void)enqueueBuffer{
    NSLog(@"EnqueueBuffer");
    
    inuse[fillBufferIndex] = true;		// set in use flag
    buffersUsed++;
    
    // enqueue buffer
    AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
    fillBuf->mAudioDataByteSize = bytesFilled;
    
    if (packetsFilled)
    {
        audioSessionMaster = AudioQueueEnqueueBuffer(audioQueue, fillBuf, packetsFilled, packetDescs);
    }
    else
    {
        audioSessionMaster = AudioQueueEnqueueBuffer(audioQueue, fillBuf, 0, NULL);
    }
    
    audioSessionMaster = AudioQueueStart(audioQueue, NULL);
    
    // go to next buffer
    if (++fillBufferIndex >= bufferSize) fillBufferIndex = 0;
    bytesFilled = 0;		// reset bytes filled
    packetsFilled = 0;		// reset packets filled
    
    //This thread-safe code seems to be important for handling the buffer so I took it from the audio streamer example
    while (inuse[fillBufferIndex])
	{
		pthread_cond_wait(&queueBufferReadyCondition, &queueBuffersMutex);
	}
    
}

#pragma mark Handle Methods

- (void)handleReadFromStream:(CFReadStreamRef)aStream{
    NSLog(@"handleReadFromStream");
    if (notStopping){
    //we need these if stateents because otherwise it continuously reads data and it sounds like garbage
    if (!httpHeaders){
        CFTypeRef message = CFReadStreamCopyProperty(aStream, kCFStreamPropertyHTTPResponseHeader);
        httpHeaders =
        (__bridge NSDictionary *)CFHTTPMessageCopyAllHeaderFields((CFHTTPMessageRef)message);
        CFRelease(message);
    }
    if (!audioFileStream) {
        AudioFileTypeID fileType = kAudioFileMP3Type;
        // create an audio file stream parser
//        NSLog(@"AudioFileStreamOpen returns: %ld",AudioFileStreamOpen((__bridge void*)self, MyPropertyListenerProc, MyPacketsProc, fileType, &audioFileStream));
        audioSessionMaster = AudioFileStreamOpen((__bridge void*)self, MyPropertyListenerProc, MyPacketsProc,
                                  fileType, &audioFileStream);
//        NSLog(@"audioSessionMaster returned: %ld",audioSessionMaster);
    }
    
    UInt8 bytes[DefaultBufSize];
    CFIndex length;      
    
    
    //
    // Read the bytes from the stream
    //
    length = CFReadStreamRead(stream, bytes, DefaultBufSize);
    
    //NSLog(@"Parsing normal bytes.");
    audioSessionMaster = AudioFileStreamParseBytes(audioFileStream, length, bytes, 0);
    }
    
    
}

- (void) handlePropertyChangeForFileStream:(AudioFileStreamID)inAudioFileStream fileStreamPropertyID:(AudioFileStreamPropertyID)inPropertyID{
    NSLog(@"handlePropertyChangeForFileStream");
    
    if (inPropertyID == kAudioFileStreamProperty_DataFormat){
        UInt32 asbdSize= sizeof(asbd);
        // get the stream format.
        audioSessionMaster = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &asbd);
    }
}

- (void)handleAudioPackets:(const void *)inInputData
             numberPackets:(UInt32)inNumberPackets
        packetDescriptions:(AudioStreamPacketDescription *)inPacketDescriptions{
    NSLog(@"handleAudioPackets");
    
    if (!audioQueue){
        [self createQueue];
    }
    
    for (int i = 0; i < inNumberPackets; ++i){
     
        SInt64 packetOffset = inPacketDescriptions[i].mStartOffset;
        SInt64 packetSize   = inPacketDescriptions[i].mDataByteSize;
        size_t bufSpaceRemaining;
        
        bufSpaceRemaining = packetBufferSize - bytesFilled;
        
        // enqueue the buffer when the space remaining is too small for a packet
        
        if (bufSpaceRemaining < packetSize)
        {
            [self enqueueBuffer];
        }
        
        //I took this because I think it's important
        if (bytesFilled + packetSize > packetBufferSize)
        {
            return;
        }
//        NSLog(@"Are we ever getting here?");
        // copy data to the audio queue buffer
        //I only want to do this if I am not trying to clear the buffers
        if (notStopping){
            AudioQueueBufferRef fillBuf = audioQueueBuffer[fillBufferIndex];
            memcpy((char*)fillBuf->mAudioData + bytesFilled, (const char*)inInputData + packetOffset, packetSize);
            // fill out packet description
            packetDescs[packetsFilled] = inPacketDescriptions[i];
            packetDescs[packetsFilled].mStartOffset = bytesFilled;
            // keep track of bytes filled and packets filled
            bytesFilled += packetSize;
            packetsFilled += 1;
        }
    }
    
    size_t packetsDescsRemaining = MaxPacketDescs - packetsFilled;
    if (packetsDescsRemaining == 0) {
        [self enqueueBuffer];
    }
    
}


// Knows when the buffer completes from the audio queue
- (void)handleBufferCompleteForQueue:(AudioQueueRef)inAQ
                              buffer:(AudioQueueBufferRef)inBuffer
{
	unsigned int bufIndex = -1;
	for (unsigned int i = 0; i < bufferSize; ++i)
	{
		if (inBuffer == audioQueueBuffer[i])
		{
			bufIndex = i;
			break;
		}
	}
    
	inuse[bufIndex] = false;
	buffersUsed--;
    
}

- (void)handlePropertyChangeForQueue:(AudioQueueRef)inAQ
                          propertyID:(AudioQueuePropertyID)inID{
    
    if (inID == kAudioQueueProperty_IsRunning){
        
        [NSRunLoop currentRunLoop];
        
    }
    
}

@end
