//
//  AKMusicTrack.swift
//  AudioKit
//
//  Created by Jeff Cooper on 12/8/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

/// Wrapper for internal Apple MusicTrack
public class AKMusicTrack{
    
    internal var internalMusicTrack = MusicTrack()
    
    /// Pointer to the Music Track
    public var trackPtr:UnsafeMutablePointer<MusicTrack>
    
    public var length:MusicTimeStamp{
        var size:UInt32 = 0
        var len = MusicTimeStamp(0)
        MusicTrackGetProperty(internalMusicTrack, kSequenceTrackProperty_TrackLength, &len, &size)
        return len
    }
    
    /// Initialize with a music track
    ///
    /// - parameter musicTrack: An Apple Music Track
    ///
    public init(musicTrack: MusicTrack) {
        internalMusicTrack = musicTrack
        trackPtr = UnsafeMutablePointer<MusicTrack>(internalMusicTrack)
    }
    
    /// Set the MIDI Ouput
    ///
    /// - parameter endpoint: MIDI Endpoint Port
    ///
    public func setMidiOutput(endpoint:MIDIEndpointRef) {
        MusicTrackSetDestMIDIEndpoint(internalMusicTrack, endpoint)
    }
    
    /// Set the Node Output
    ///
    /// - parameter node: Apple AUNode for output
    ///
    public func setNodeOutput(node: AUNode) {
        MusicTrackSetDestNode(internalMusicTrack, node)
    }
    
    /// Set loop info
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    /// - paramter numberOfLoops: how many times to loop. 0 is infinte
    ///
    public func setLoopInfo(duration: Double, numberOfLoops: Int){
        let size:UInt32 = 0
        let len = MusicTimeStamp(duration)
        var loopInfo = MusicTrackLoopInfo(loopDuration: len, numberOfLoops: Int32(numberOfLoops))
        MusicTrackSetProperty(internalMusicTrack, kSequenceTrackProperty_LoopInfo, &loopInfo, size)
    }
   
    /// Set length
    ///
    /// - parameter duration: How long the loop will last, from the end of the track backwards
    ///
    public func setLength(duration: Double){
        let size:UInt32 = 0
        var len = MusicTimeStamp(duration)
        var tmpSeq:MusicSequence = nil
        var seqPtr:UnsafeMutablePointer<MusicSequence>
        var tmpTrack = MusicTrack()
        seqPtr = UnsafeMutablePointer<MusicSequence>(tmpSeq)
        NewMusicSequence(&tmpSeq)
        MusicTrackGetSequence(internalMusicTrack, seqPtr)
        MusicSequenceNewTrack(tmpSeq, &tmpTrack)
        MusicTrackSetProperty(tmpTrack, kSequenceTrackProperty_TrackLength, &len, size)
        MusicTrackCopyInsert(internalMusicTrack, 0, len, tmpTrack, 0)
        clear()
        MusicTrackSetProperty(internalMusicTrack, kSequenceTrackProperty_TrackLength, &len, size)
        MusicTrackCopyInsert(tmpTrack, 0, len, internalMusicTrack, 0)
        MusicSequenceDisposeTrack(tmpSeq, tmpTrack)
    }
    
    /// Clear all events from the track
    public func clear(){
        MusicTrackClear(internalMusicTrack, 0, length)
    }
    
    public func debug(){
        CAShow(trackPtr)
    }
}