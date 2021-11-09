Extension { #name : #MemoryLogger }

{ #category : #'*FFICallLogger' }
MemoryLogger >> shallowCopy [

	"This accessor answers a copy of the internal collection."
	^ self class withRecordings: self recordings
]
