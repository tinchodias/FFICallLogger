Extension { #name : #DateAndTime }

{ #category : #'*FFICallLogger' }
DateAndTime class >> tflEpochValue [ 

	self flag: #todo. "The SharedPool name renamed in Pharo 13" 
	^ ((self bindingOf: #Epoch) ifNil: [ (self bindingOf: #SqueakEpoch) ]) value.

]

{ #category : #'*FFICallLogger' }
DateAndTime class >> tflFromMicrosecondClockValue: anInteger [

	| nanoTicks |
	nanoTicks := anInteger * 1000.
	^ self basicNew
		setJdn: self tflEpochValue 
		seconds: 0
		nano: nanoTicks
		offset: self localOffset
]
