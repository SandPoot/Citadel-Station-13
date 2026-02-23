import { max } from 'common/math';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, Icon, LabeledList, ProgressBar, Section, Stack, Table, Tabs, TextArea } from '../components';
import { ButtonConfirm } from '../components/Button';
import { TableCell, TableRow } from '../components/Table';
import { Window } from '../layouts';

type CircuitPrinter = {
  materialAmount: number;
  materialMaxAmount: number;
  upgrade: boolean;
  debug: boolean;
  canClone: boolean;
  fastClone: boolean;
  cloning: boolean;
  program: boolean;

  categories: Categories;
}

type Categories = {
  [index: string]: Array<Item>;
}

type Item = {
  name: string,
  desc: string,
  cost: number,
  path: string,
  icon: string,
  can_build: boolean,
  complexity: number,
  size: number,
}

export const IntegratedCircuitPrinter = (props, context) => {
  const { act, data } = useBackend<CircuitPrinter>(context);
  const {
    materialAmount,
    materialMaxAmount,
    upgrade,
    debug,
    canClone,
    fastClone,
    cloning,
    program,
  } = data;
  const categories = data.categories || [];
  const [activeCategory, setCategory] = useLocalState(context, "activeCategory", Object.keys(categories)[0]);
  return (
    <Window resizable width={800} height={630} title="Integrated Circuit Printer">
      <Window.Content>
        <Section fill>
          <Stack vertical fill>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Material">
                  {debug
                    ? <marquee>DEBUG PRINTER -- Infinite materials. Cloning available.</marquee>
                    : (
                      <ProgressBar value={materialMaxAmount - materialAmount} maxValue={materialMaxAmount} color="black" backgroundColor={"#878687"} style={{
                        transform: 'scaleX(-1) scaleY(1)',
                      }}>
                        <div style={{ transform: 'scaleX(-1)' }}>{materialAmount} cm³ / {materialMaxAmount} cm³</div>
                      </ProgressBar>
                    )}
                </LabeledList.Item>
                {!!(canClone || debug)
                  && (
                    <LabeledList.Item label="Assembly Cloning">
                      {(fastClone || debug) ? "Instant" : "Available"}<br />
                      {!upgrade && "Crossed out circuits mean that the printer is not sufficiently upgraded to create that circuit."}
                    </LabeledList.Item>
                  )}
                <LabeledList.Item label="Circuits Available">
                  {upgrade || debug ? "Advanced" : "Regular"}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            {!!(canClone || debug)
              && (
                <>
                  <Stack.Divider />
                  <Collapsible title="Here you can load script for your assembly" color="transparent" mt="2px">
                    <Stack fill height="10vh" vertical={cloning}>
                      {cloning
                        ? (
                          <>
                            <Stack.Item grow textAlign="center">
                              <Icon name="spinner" spin size="4" />
                            </Stack.Item>
                            <Stack.Item textAlign="center">
                              <ButtonConfirm content="Cancel" color="red" onClick={() => act("clone", {
                                option: "cancel",
                              })} />
                            </Stack.Item>
                          </>
                        ) : (
                          <>
                            <Stack.Item grow>
                              <TextArea
                                fluid
                                height="100%"
                                placeholder="A program is still loaded and can be printed"
                                onChange={(e, value) => act("clone", {
                                  option: "load",
                                  content: value,
                                })} />
                            </Stack.Item>
                            <Stack.Item>
                              <ButtonConfirm
                                fluid
                                icon="file-import"
                                height="100%"
                                center
                                verticalAlign="center"
                                fontSize="6vh"
                                onClick={() => act("clone", {
                                  option: "print",
                                })} />
                            </Stack.Item>
                          </>
                        )}
                    </Stack>
                  </Collapsible>
                </>
              )}
            <Stack.Divider />
            <Stack.Item>
              <Tabs fill fluid style={{ 'flex-wrap': "wrap" }}>
                {Object.keys(categories).map((category, key) => (
                  <Tabs.Tab key={key} fluid align="center" onClick={() => setCategory(category)}
                    selected={activeCategory === category}>
                    {category}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Item grow basis={0} overflowY="auto">
              <Table>
                <TableRow header backgroundColor={"rgba(0, 0, 0, 0.50)"}>
                  <TableCell />
                  <TableCell>
                    Name
                  </TableCell>
                  <TableCell>
                    Description
                  </TableCell>
                  <TableCell>
                    Complexity
                  </TableCell>
                  <TableCell>
                    Size
                  </TableCell>
                  <TableCell>
                    Cost
                  </TableCell>
                </TableRow>
                {!!activeCategory
                && categories[activeCategory].map(item => (
                  <TableRow key={item.ref} className="candystripe" color={item.can_build ? "" : "grey"}>
                    {item.can_build
                      ? <EntryItem item={item} />
                      : (
                        <s>
                          <EntryItem item={item} />
                        </s>
                      )}
                  </TableRow>
                ))}
              </Table>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

export const EntryItem = (props, context) => {
  const { act, data } = useBackend<CircuitPrinter>(context);
  const {
    materialAmount,
    debug,
  } = data;
  const { item } = props;
  return (
    <>
      <TableCell collapsing>
        <span
          className={classes([
            'integrated_circuits32x32',
            item.icon,
          ])}
          style={{
            'vertical-align': 'middle',
            'horizontal-align': 'middle',
          }} />
      </TableCell>
      <TableCell bold>
        {item.name}
      </TableCell>
      <TableCell>
        <Box color="grey">
          {item.desc}
        </Box>
      </TableCell>
      <TableCell collapsing>
        <Box textAlign="center">
          {item.complexity}
        </Box>
      </TableCell>
      <TableCell collapsing>
        <Box textAlign="center">
          {item.size}
        </Box>
      </TableCell>
      <TableCell collapsing>
        <Button
          content={item.cost}
          disabled={!item.can_build || !(debug || (max(materialAmount - item.cost, 0)))}
          onClick={() => act("print", {
            build: item.path,
          })}
        />
      </TableCell>
    </>
  );
};
