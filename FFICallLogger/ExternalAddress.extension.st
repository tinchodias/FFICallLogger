Extension { #name : #ExternalAddress }

{ #category : #'*FFICallLogger' }
ExternalAddress >> asFFILoggerRecording [
	"Self is mutated on free as null, so answer a new object that won't change."

	| sz |
	sz := self size.
	^ (FFICallLoggerAddress basicNew: sz)
		replaceFrom: 1 to: sz with: self startingAt: 1
]
