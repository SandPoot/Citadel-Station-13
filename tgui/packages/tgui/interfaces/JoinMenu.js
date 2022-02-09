/* eslint-disable max-len */
import { useBackend } from '../backend';
import { Button, Collapsible, Section, Table } from '../components';
import { Window } from '../layouts';

export const JoinMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { charname, duration, evacuated, jobs, security_level } = data;
  return (
    <Window width={400} height={600} overflow="auto">
      <Window.Content>
        <Section title={"Welcome " + charname}>
          Shift has lasted {duration}<br />
          The current alert level is {security_level}<br />
          {evacuated ? "The Station is under evacuation procedures." : null}
        </Section>
        <Section title="Join a Shift" overflow="hidden">
          {
            Object.keys(jobs).map(faction => (
              <Collapsible title={faction} key={faction} color="transparent">
                {
                  Object.keys(jobs[faction]).map(job => (
                    <Collapsible title={job} key={job} color="transparent" style={{ "padding-left": "5%" }}>
                      <Section style={{ "padding-left": "5%" }}>
                        <Table>
                          {
                            Object.keys(jobs[faction][job]).map(rank => (
                              <tr class="Table__row candystripe" key={rank}>
                                <Collapsible title={rank} color="transparent" style={{ "padding-left": "5%" }} buttons={
                                  <Button
                                    icon="sign-in-alt"
                                    content="Join"
                                    onClick={() => act('join', {
                                      id: jobs[faction][job][rank].id,
                                      type: "job",
                                    })} />
                                }>
                                  <Section style={{ "padding-left": "5%" }}>
                                    Description: {jobs[faction][job][rank].desc}
                                    <td>
                                      Free slots: {jobs[faction][job][rank].slots}
                                    </td>
                                  </Section>
                                </Collapsible>
                              </tr>
                            ))
                          }
                        </Table>
                      </Section>
                    </Collapsible>
                  ))
                }
              </Collapsible>
            ))
          }
        </Section>
      </Window.Content>
    </Window>
  );
};
