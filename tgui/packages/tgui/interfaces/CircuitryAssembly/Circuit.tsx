import { decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Input, Section, Stack, Icon, Flex } from '../../components';

import { expectedData } from './types';

const buttonHeight = "80px";
const pinBasis = 5;

export const IC_FORMAT = {
  ANY: "<ANY>",
  STRING: "<TEXT>",
  CHAR: "<CHAR>",
  COLOR: "<COLOR>",
  NUMBER: "<NUM>",
  DIR: "<DIR>",
  BOOLEAN: "<BOOL>",
  REF: "<REF>",
  LIST: "<LIST>",
  INDEX: "<INDEX>",
};

export const ProgrammingWindow = (props, context) => {
  const { act, data } = useBackend<expectedData>(context);
  const circuits = data.circuits || [];
  const [currentCircuit, setCircuit] = useLocalState<string | null>(context, "currentCircuit", null);
  const circuit = circuits.find(c => c.ref === currentCircuit);

  if (!circuit) {
    return (
      <Section title="Select a component to begin editing" fill>
        <Flex fill justify="center" align="center">
          <Icon name="terminal" size={32} color="grey" />
        </Flex>
      </Section>
    );
  }

  else {
    return (
      <Section
        title={circuit.type}
        fill
        scrollable
        buttons={
          <Stack
            width="30vw"
            fill
          >
            <Stack.Item grow>
              <Input
                fluid
                placeholder="Name it something!"
                value={circuit.name}
                onChange={(e, value) => act("rename_circuit",
                  {
                    circuit: circuit.ref,
                    new_name: value,
                  })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="clipboard"
                color="transparent"
                tooltip="Copy reference"
                onClick={() => act("scan", {
                  circuit: circuit.ref,
                })}
              />
            </Stack.Item>
          </Stack>
        }
      >
        <Circuit />
      </Section>
    );
  }
};

export const Circuit = (props, context) => {
  const { act, data } = useBackend<expectedData>(context);
  const { data_ref } = data;
  const circuits = data.circuits || [];
  const [currentCircuit, setCircuit] = useLocalState(context, "currentCircuit", null);
  const circuit = circuits.find(c => c.ref === currentCircuit);
  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow basis={0}>
            <Stack vertical fill>
              {circuit.inputs.map(input_entry =>
                (
                  <PinTemplate key={input_entry.ref} input_entry={input_entry} />
                )
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack ml="2px" mr="2px" pl="5px" pr="5px" pt="3px" minHeight="200px" height="100%" backgroundColor="black" style={{ outline: "solid green 2px" }}>
              {circuit.long_desc || "There is no additional information available."}
            </Stack>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack vertical fill>
              {circuit.outputs.map(output_entry =>
                (
                  <PinTemplate key={output_entry.ref} input_entry={output_entry} />
                )
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Stack vertical fill>
          {circuit.activators.map(activator_entry =>
            (
              <Stack.Item key={activator_entry.index} align="center" height={buttonHeight} minWidth="400px">
                <Stack vertical fill>
                  <Stack.Item grow basis={0}>
                    <Stack fill>
                      <Stack.Item grow basis={9}>
                        <Button
                          content={activator_entry.name}
                          tooltip={activator_entry.name}
                          fluid
                          height="100%"
                          align="center"
                          ellipsis
                          selected={activator_entry.ref === data_ref}
                          onClick={() => act("pin", {
                            circuit: circuit.ref,
                            pin: activator_entry.ref,
                            act: "wire",
                          })}
                        />
                      </Stack.Item>
                      <Stack.Item grow basis={0}>
                        <Button
                          content={decodeHtmlEntities(activator_entry.type)}
                          tooltip={decodeHtmlEntities(activator_entry.type)}
                          fluid
                          height="100%"
                          align="center"
                          ellipsis
                          onClick={() => act("pin", {
                            circuit: circuit.ref,
                            pin: activator_entry.ref,
                            act: "data",
                          })}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  {!!activator_entry.links.length
                      && (
                        <Stack.Item grow basis={0}>
                          <Section fill overflowY={activator_entry.links.length > 1 ? "auto" : ""}>
                            {activator_entry.links.map(link => (
                              <Stack key={link.source} mb="2px">
                                <Stack.Item grow basis={0}>
                                  <Button
                                    key={link.source}
                                    content={link.name}
                                    tooltip={link.name}
                                    fluid
                                    ellipsis
                                    selected={link.pin === data_ref}
                                    onClick={() => act("pin", {
                                      circuit: circuit.ref,
                                      pin: activator_entry.ref,
                                      link: link.pin,
                                      act: "unwire",
                                    })}
                                  />
                                </Stack.Item>
                                <Stack.Item>
                                  <Icon name="link" />
                                </Stack.Item>
                                <Stack.Item grow basis={0}>
                                  <Button
                                    key={link.source}
                                    content={circuits.find(c => c.ref === link.source).name}
                                    tooltip={circuits.find(c => c.ref === link.source).name}
                                    fluid
                                    ellipsis
                                    onClick={() => setCircuit(link.source)}
                                  />
                                </Stack.Item>
                              </Stack>
                            ))}
                          </Section>
                        </Stack.Item>
                      )}
                </Stack>
              </Stack.Item>
            )
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const PinTemplate = (props, context) => {
  const { act, data } = useBackend<expectedData>(context);
  const { data_ref } = data;
  const circuits = data.circuits || [];
  const [currentCircuit, setCircuit] = useLocalState(context, "currentCircuit", null);
  const circuit = circuits.find(c => c.ref === currentCircuit);
  const { input_entry } = props;

  return (
    <Stack.Item key={input_entry.index} height={buttonHeight}>
      <Stack vertical fill>
        <Stack.Item grow basis={0}>
          <Stack fill>
            <Stack.Item grow basis={9}>
              <Button
                content={
                  <>
                    <Box fontSize="10px" mb="-0.8em">{decodeHtmlEntities(input_entry.type)}</Box>
                    <Box>{input_entry.name}</Box>
                  </>
                }
                fluid
                height="100%"
                align="center"
                selected={input_entry.ref === data_ref}
                onClick={() => act("pin", {
                  circuit: circuit.ref,
                  pin: input_entry.ref,
                  act: "wire",
                })}
              />
            </Stack.Item>
            <Stack.Item grow basis={0}>
              <Button
                content={decodeHtmlEntities(input_entry.data)}
                tooltip={decodeHtmlEntities(input_entry.data)}
                fluid
                height="100%"
                align="center"
                ellipsis
                onClick={() =>
                  act("pin", {
                    circuit: circuit.ref,
                    pin: input_entry.ref,
                    act: "data",
                  })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {!!input_entry.links.length
          && (
            <Stack.Item grow basis={0}>
              <Section fill overflowY={input_entry.links.length > 1 ? "auto" : ""}>
                {input_entry.links.map(link => (
                  <Stack key={link.source} mb="2px">
                    <Stack.Item grow basis={0}>
                      <Button
                        key={link.source}
                        content={link.name}
                        tooltip={link.name}
                        fluid
                        ellipsis
                        selected={link.pin === data_ref}
                        onClick={() => act("pin", {
                          circuit: circuit.ref,
                          pin: input_entry.ref,
                          link: link.pin,
                          act: "unwire",
                        })}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Icon name="link" />
                    </Stack.Item>
                    <Stack.Item grow basis={0}>
                      <Button
                        key={link.source}
                        content={circuits.find(c => c.ref === link.source).name}
                        tooltip={circuits.find(c => c.ref === link.source).name}
                        fluid
                        ellipsis
                        onClick={() => setCircuit(link.source)}
                      />
                    </Stack.Item>
                  </Stack>
                ))}
              </Section>
            </Stack.Item>
          )}
      </Stack>
    </Stack.Item>
  );
};
