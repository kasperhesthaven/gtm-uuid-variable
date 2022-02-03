___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "UUIDv4",
  "description": "Generates a RFC4122 compliant UUIDv4 (e.g., 61f04ef1-76c3-4880-8775-2df0486d2f01) on \u003cstrong\u003eevery\u003c/strong\u003e use.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "CHECKBOX",
    "name": "idIsConstantPerEvent",
    "checkboxText": "Make UUID static per event",
    "simpleValueType": true,
    "help": "This will assign the UUIDv4 once per event (\u003ci\u003ee.g. gtm.load\u003c/i\u003e) to template storage, which will be used for subsequent uses during the event, rather than a new UUID per use.\nUse this if doing event-based deduplication.",
    "defaultValue": false,
    "alwaysInSummary": true,
    "clearOnCopy": true,
    "displayName": "Event constant"
  },
  {
    "type": "CHECKBOX",
    "name": "idIsConstantPerPage",
    "checkboxText": "Make UUID static per page",
    "simpleValueType": true,
    "help": "This will assign the UUIDv4 once per page to template storage, which will be used for subsequent uses while on the same page, rather than a new UUID per use.\nUse this if doing page-based deduplication.",
    "defaultValue": false,
    "alwaysInSummary": true,
    "clearOnCopy": true
  },
  {
    "type": "GROUP",
    "name": "descriptionGroup",
    "displayName": "Description",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "LABEL",
        "name": "usageNote",
        "displayName": "Generates a RFC4122 compliant UUIDv4 \u003ci\u003e(e.g. 61f04ef1-76c3-4880-8775-2df0486d2f01)\u003c/i\u003e on \u003cstrong\u003eevery\u003c/strong\u003e use. \u003c/br\u003e\u003ci\u003eApproximate load: 0.004ms each use.\u003c/i\u003e"
      },
      {
        "type": "LABEL",
        "name": "rngQualityNote",
        "displayName": "\u003cstrong\u003eRNG Quality\u003c/strong\u003e\u003cbr /\u003e Quality of randomness depends on how the end user\u0027s browser has implemented Math.random(), but in general you have a \u003e1:1.000.000 risk of collisions, however Math.random() is \u003ci\u003enever\u003c/i\u003e cryptographically secure."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "contactGroup",
    "displayName": "Contact",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "LABEL",
        "name": "contactNote",
        "displayName": "Pull requests welcome at \u003ca href\u003d\"https://github.com/kasperhesthaven/gtm-uuid-variable\"\u003ehttps://github.com/kasperhesthaven/gtm-uuid-variable\u003c/a\u003e",
        "enablingConditions": []
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const generateRandom = require('generateRandom');
const Math = require('Math');
const templateStorage = require('templateStorage');
const copyFromDataLayer = require('copyFromDataLayer');

/**
 * Convert postive decimal to any valid radix base number
 *
 * As GTM's sandbox Number.toString() doesn't take a parameter this implements the
 * ESMA262 equivalent, albeit without its error handling & edge cases.
 *
 * @param {number} uint          Positive integer to be parsed.
 * @param {number} [radix=10]    Radix to parse uint based on (2-36 allowed).
 *
 * @return {string} String representation of input integer in the specified radix.
 */

// radixSymbols is declared outside uintToRadix() for v8 optimization,
// with little readability sacrificed.
const radixSymbols = [
	'0',
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	'A',
	'B',
	'C',
	'D',
	'E',
	'F',
	'G',
	'H',
	'I',
	'J',
	'K',
	'L',
	'M',
	'N',
	'O',
	'P',
	'Q',
	'R',
	'S',
	'T',
	'U',
	'V',
	'W',
	'X',
	'Y',
	'Z'
];
function uintToRadix(uint, radix) {
	if (uint < 1) return uint;
	if (radix < 2 || radix > 36) return;
	radix = radix || 10;
	let returnValue = '';

	while (uint != 0) {
		const rest = uint % radix;
		uint = Math.floor(uint / radix);
		returnValue = radixSymbols[rest] + returnValue;
	}
	return returnValue;
}

/**
 * Generate a RFC4122 compliant UUIDv4.
 *
 * @return {string} Psuedo-random generated UUIDv4 as a string.
 */
function generateUUIDv4() {
	const uuid = [
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'-',
		'x',
		'x',
		'x',
		'x',
		'-',
		'4',
		'x',
		'x',
		'x',
		'-',
		'y',
		'x',
		'x',
		'x',
		'-',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x',
		'x'
	];

	return uuid
		.map((char) => {
			const randomNumber = generateRandom(0, 15);
			if (char === 'x') return uintToRadix(randomNumber, 16);
			if (char === 'y') return uintToRadix((randomNumber & 3) | 8, 16);
			return char;
		})
		.join('');
}

if (data.idIsConstantPerPage) {
  const lastUUID = templateStorage.getItem('lastPageUUID');
  
  // UUID has been set before
  if (lastUUID) return lastUUID;
  
  const uuid = generateUUIDv4();
  templateStorage.setItem('lastPageUUID', uuid);
  return uuid;
}

if (data.idIsConstantPerEvent) {
	const lastEvent = templateStorage.getItem('lastEvent');
	const currentEvent = copyFromDataLayer('event');

	if (lastEvent === currentEvent) return templateStorage.getItem('lastEventUUID');

	if (lastEvent === null || lastEvent !== currentEvent) {
		const uuid = generateUUIDv4();
		templateStorage.setItem('lastEvent', currentEvent);
		templateStorage.setItem('lastEventUUID', uuid);
		return uuid;
	}
}

return generateUUIDv4();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "event"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Replacement has occurred
  code: |-
    let templateResult = runCode();
    assertThat(templateResult.indexOf('x')).isEqualTo(-1);
    assertThat(templateResult.indexOf('y')).isEqualTo(-1);
    assertThat(templateResult.charAt(14)).isEqualTo('4');
- name: No collisions in 1000 executions
  code: |-
    const UUIDv4Sets = [];

    for (let i = 0; i < 1000; i++) {
      UUIDv4Sets.push(runCode());

      if (UUIDv4Sets.filter((item, index) => UUIDv4Sets.indexOf(item) != index).length !== 0) {
        fail('Collision occurred after ' + i + ' iteration(s)');
      }
    }

    assertThat(UUIDv4Sets).hasLength(1000);


___NOTES___

How likely is a collision?
It depends entirely on the end user's device.
In a rudimentary test of 200m iterations in Chrome I didn't personally experience any collisions

Why not use the Web Crypto API?
It's not available amongst the Google Tag Manager sandbox APIs.

Why not split those long arrays?
I figure this code will rarely be read, so while 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.split(''),
would be preferable the relative effect it has on performance is awful. 
3x slower or so, though microbenchmarks are misleading.


