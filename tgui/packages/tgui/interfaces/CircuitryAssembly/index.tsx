import { useBackend, useLocalState } from '../../backend';
import { Box, Button, Input, ProgressBar, Section, Stack, Tabs, Tooltip } from '../../components';
import { Window } from '../../layouts';
import { ProgrammingWindow } from './Circuit';

import { expectedData } from './types';

export const CircuitryAssembly = (props, context) => {
  const { act, data } = useBackend<expectedData>(context);
  const {
    name,

    total_part_size,
    max_components,

    total_complexity,
    max_complexity,

    battery_charge,
    battery_maxcharge,
  } = data;
  return (
    <Window
      width={940}
      height={650}
      buttons={(
        <Box
          width="40vw"
          position="absolute"
          top="5px"
          height="22px"
        >
          <Input
            fluid
            placeholder="Name it something!"
            value={name}
            onChange={(e, value) => act("rename", { new_name: value })}
          />
        </Box>
      )}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Information">
              <ProgressBar
                value={total_part_size / max_components}
                mb="5px"
                ranges={{
                  good: [0, 0.33],
                  average: [0.33, 0.66],
                  bad: [0.66, 1],
                }}>
                {total_part_size}/{max_components} ({(total_part_size / max_components) * 100}%) space taken up in the assembly
              </ProgressBar>
              <ProgressBar
                value={total_complexity / max_complexity}
                mb="5px"
                ranges={{
                  good: [0, 0.33],
                  average: [0.33, 0.66],
                  bad: [0.66, 1],
                }}>
                {total_complexity}/{max_complexity} ({(total_complexity / max_complexity) * 100}%) maximum complexity
              </ProgressBar>
              {battery_charge === null
                ? <Box textAlign="right">No power cell detected!</Box>
                : (
                  <Stack fill>
                    <Stack.Item grow>
                      <ProgressBar
                        value={battery_charge / battery_maxcharge}
                        ranges={{
                          bad: [0, 0.33],
                          average: [0.33, 0.66],
                          good: [0.66, 1],
                        }}>
                        {battery_charge}/{battery_maxcharge} ({(battery_charge / battery_maxcharge) * 100}%) cell charge
                      </ProgressBar>
                    </Stack.Item>
                    <Stack.Item>
                      <Button icon="eject" color="transparent" compact onClick={() => act("remove_cell")} />
                    </Stack.Item>
                  </Stack>
                )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow>
                <ComponentList />
              </Stack.Item>
              <Stack.Item grow width="60%">
                <ProgrammingWindow />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const ComponentList = (props, context) => {
  const { act, data } = useBackend<expectedData>(context);
  const circuits = data.circuits;
  const [currentCircuit, setCircuit] = useLocalState(context, "currentCircuit", null);
  return (
    <Section title="Components" fill scrollable buttons={
      <Button icon="info" tooltip="Shift-click arrows to skip to top or bottom" color="transparent" />
    }>
      <Tabs vertical>
        {circuits && circuits.map(circuit =>
          (
            <Tooltip
              content={
                <>
                  <Box>Type: {circuit.type}</Box>
                  <Box>Complexity: {circuit.complexity}</Box>
                  <Box>Size: {circuit.size}</Box>
                  <Box>Cooldown per use: {circuit.cooldown_per_use * 0.1} sec{(circuit.cooldown_per_use * 0.1) !== 1 ? "s" : null}</Box>
                  <br />
                  <Box>{circuit.desc}</Box>
                </>
              }
              key={circuit.ref}
            >
              <Tabs.Tab
                key={circuit.ref}
                selected={currentCircuit === circuit.ref}
                onClick={() => setCircuit(circuit.ref)}
                align="center"
                style={{ 'display': "block" }}
                className={currentCircuit === circuit.ref ? "" : "candystripe"}
                rightSlot={(
                  <>
                    <Button.Input
                      icon="share"
                      tooltip="Jump"
                      color="transparent"
                      onCommit={(ev, value) => {
                        act("move", {
                          circuit: circuit.ref,
                          direction: value,
                        });
                      }}
                    />
                    <Button
                      icon="arrow-up"
                      tooltip="Move up"
                      color="transparent"
                      onClick={(ev) => {
                        ev.stopPropagation();
                        if (ev.shiftKey) {
                          act("move", {
                            circuit: circuit.ref,
                            direction: 1,
                          }); }
                        else {
                          act("move", {
                            circuit: circuit.ref,
                            direction: "up",
                          }); }
                      }}
                    />
                    <Button
                      icon="arrow-down"
                      tooltip="Move down"
                      color="transparent"
                      onClick={(ev) => {
                        ev.stopPropagation();
                        if (ev.shiftKey) {
                          act("move", {
                            circuit: circuit.ref,
                            direction: circuits.length,
                          }); }
                        else {
                          act("move", {
                            circuit: circuit.ref,
                            direction: "down",
                          }); }
                      }}
                    />
                    <Button.Confirm
                      icon="times"
                      tooltip="Remove"
                      color="transparent"
                      onClick={(ev) => {
                        ev.stopPropagation();
                        if (circuit === currentCircuit) {
                          setCircuit(null);
                        }
                        act("remove", {
                          circuit: circuit.ref,
                        });
                      }}
                    />
                  </>
                )}>
                {circuit.name}
              </Tabs.Tab>
            </Tooltip>
          )
        )}
      </Tabs>
    </Section>
  );
};
