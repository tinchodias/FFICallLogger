Extension { #name : #ExternalAddress }

{ #category : #'*FFICallLogger' }
ExternalAddress >> asTFLRecording [
	"Self is mutated on free as null, so answer a new object that won't change."

	^ self isNull
		ifTrue:[ TFLNullAddress instance ]
		ifFalse: [ TFLAddress newFrom: self ]

]
