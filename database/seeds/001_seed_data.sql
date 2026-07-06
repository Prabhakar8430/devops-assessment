INSERT INTO hotel_bookings
(
    org_id,
    hotel_id,
    city,
    checkin_date,
    checkout_date,
    amount,
    status,
    created_at
)
SELECT

gen_random_uuid(),

'Hotel-' || gs,

(
ARRAY[
'delhi',
'mumbai',
'pune',
'nagpur',
'hyderabad',
'bangalore'
]
)[1 + floor(random()*6)::int],

CURRENT_DATE + (random()*30)::int,

CURRENT_DATE + (random()*35)::int,

(random()*15000+1000)::numeric(12,2),

(
ARRAY[
'CONFIRMED',
'CANCELLED',
'PENDING'
]
)[1 + floor(random()*3)::int],

NOW() - (random()*60 || ' days')::interval

FROM generate_series(1,100) gs;

INSERT INTO booking_events
(
booking_id,
event_type,
payload,
created_at
)

SELECT

id,

'BOOKING_CREATED',

jsonb_build_object(

'source','website',

'user','system'

),

created_at

FROM hotel_bookings

LIMIT 60;