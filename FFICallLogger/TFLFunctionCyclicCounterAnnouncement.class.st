"
I represent a completed cycle in a `TFLFunctionCyclicCounter`, and hold the relevant information.
"
Class {
	#name : 'TFLFunctionCyclicCounterAnnouncement',
	#superclass : 'Announcement',
	#instVars : [
		'functionNamesAndCounts',
		'waitedMS',
		'stopMS',
		'startMS'
	],
	#category : 'FFICallLogger-Counter',
	#package : 'FFICallLogger',
	#tag : 'Counter'
}

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> countMSRatio [

	^ waitedMS / self elapsedMS asFloat
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> elapsedMS [

	^ stopMS - startMS
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> functionNamesAndCounts [

	^ functionNamesAndCounts
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> functionNamesAndCounts: anObject [

	functionNamesAndCounts := anObject
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> functionNamesAndCountsAdjusted [

	| rows |
	rows := SortedCollection sortUsing: [ :a :b | a second > b second ].
	functionNamesAndCounts keysAndValuesDo: [ :key :value |
		rows add: {
			key.
			value * self countMSRatio } ].
	^ rows	
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> startMS [

	^ startMS
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> startMS: anObject [

	startMS := anObject
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> stopMS [

	^ stopMS
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> stopMS: anObject [

	stopMS := anObject
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> waitedMS [

	^ waitedMS
]

{ #category : 'accessing' }
TFLFunctionCyclicCounterAnnouncement >> waitedMS: anObject [

	waitedMS := anObject
]
