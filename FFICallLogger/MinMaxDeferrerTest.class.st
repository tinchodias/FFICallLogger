Class {
	#name : #MinMaxDeferrerTest,
	#superclass : #TestCase,
	#instVars : [
		'count',
		'deferrer'
	],
	#category : #'FFICallLogger-Tests'
}

{ #category : #accessing }
MinMaxDeferrerTest >> count [

	^ count
]

{ #category : #accessing }
MinMaxDeferrerTest >> count: anInteger [ 

	count := anInteger
]

{ #category : #accessing }
MinMaxDeferrerTest >> increase [

	count := count + 1
]

{ #category : #tests }
MinMaxDeferrerTest >> testSchedule [

	self count: 0.
	deferrer := MinMaxDeferrer
		value: (MessageSend receiver: self selector: #increase)
		notBefore: 50 milliSeconds
		notAfter: 100 milliSeconds.

	deferrer schedule.

	self assert: self count equals: 0.
	(Delay forMilliseconds: 100) wait.
	self assert: self count equals: 1.
]

{ #category : #tests }
MinMaxDeferrerTest >> testScheduleMultipleTimes [

	self count: 0.
	deferrer := MinMaxDeferrer
		value: (MessageSend receiver: self selector: #increase)
		notBefore: 150 milliSeconds
		notAfter:  200 milliSeconds.

	3 timesRepeat: [
		deferrer schedule.
		Processor yield.
		self assert: self count equals: 0 ].
	
	(Delay forMilliseconds: 200) wait.
	
	self assert: self count equals: 1.
]
