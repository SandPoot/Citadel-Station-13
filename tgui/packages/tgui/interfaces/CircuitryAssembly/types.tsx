
export type expectedData = {
  "name": string;
  "circuits": circuitType[];

  "total_part_size": number;
  "max_components": number;

  "total_complexity": number;
  "max_complexity": number;

  "battery_charge": number;
  "battery_maxcharge": number;

  "data_ref": string;
}

export type circuitType = {
  "name": string;
  "desc": string;
  "long_desc": string;
  "removable": boolean;
  "ref": string;
  "complexity": number;
  "size": number;
  "type": string;
  "cooldown_per_use": number;
  "inputs": pinType[];
  "outputs": pinType[];
  "activators": pinType[];
}

export type pinType = {
  "index": number;
  "name": string;
  "ref": string;
  "type": string;
  "data": any;
  "links": linkType[];
}

export type linkType = {
  "name": string;
  "pin": string;
  "source": string;
}
