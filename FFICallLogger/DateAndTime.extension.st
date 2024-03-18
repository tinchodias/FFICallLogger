Extension { #name : 'DateAndTime' }

{ #category : '*FFICallLogger' }
DateAndTime class >> fromMicrosecondClockValue: anInteger [

	| nanoTicks |
	nanoTicks := anInteger * 1000.
	^ self basicNew
		setJdn: SqueakEpoch 
		seconds: 0
		nano: nanoTicks
		offset: self localOffset
]
