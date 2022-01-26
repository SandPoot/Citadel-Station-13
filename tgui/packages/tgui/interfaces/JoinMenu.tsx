import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

type JoinMenuData = {

}

export const JoinMenu = (props, context) => {
  const { act, data } = useBackend<JoinMenuData>(context);

};
