Extension { #name : #ExternalAddress }

{ #category : #'*FFICallLogger' }
ExternalAddress >> asFFILoggerRecording [
	"Self is mutated on free as null, so answer a new object that won't change."

	| sz |
	^(FFICallLoggerAddress basicNew: (sz := self size))
		replaceFrom: 1 to: sz with: self startingAt: 1 "answers self"
]
