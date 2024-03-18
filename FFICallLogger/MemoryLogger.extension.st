Extension { #name : 'MemoryLogger' }

{ #category : '*FFICallLogger' }
MemoryLogger >> initializeWithRecordings: aCollection [
	"Set the collection as the recordings. Assumes that #initialize was called before."

	recordings := aCollection
]

{ #category : '*FFICallLogger' }
MemoryLogger class >> withRecordings: aCollection [

	^ self new
		  initializeWithRecordings: aCollection;
		  yourself
]
