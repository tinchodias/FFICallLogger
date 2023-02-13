Extension { #name : #MemoryLogger }

{ #category : #'*FFICallLogger' }
MemoryLogger >> initializeWithRecordings: aCollection [
	"Set the collection as the recordings. Assumes that #initialize was called before."

	recordings := aCollection
]

{ #category : #'*FFICallLogger' }
MemoryLogger >> shallowCopy [

	"The #recordings accessor answers a copy of the internal collection."
	^ self class withRecordings: self recordings
]

{ #category : #'*FFICallLogger' }
MemoryLogger class >> withRecordings: aCollection [

	^ self new
		  initializeWithRecordings: aCollection;
		  yourself
]
