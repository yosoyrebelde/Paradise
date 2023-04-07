import { useBackend } from '../backend';
import { Box, Button, Flex, NumberInput, Fragment, Section, Icon, Divider, Collapsible } from '../components';
import { Window } from '../layouts';

export const PaperSheet = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    content,
  } = data;

  return (
    <Window resizable>
      <Window.Content>
        <PaperSheetFrame
          content={content}
        />
      </Window.Content>
    </Window>
  );
};

const PaperSheetFrame = props => {
  const {
    frameWidth,
    frameHeight,
    paperWidth,
    paperHeight,
    content,
  } = props;
  return (
    <Box
      overflow="auto"
      width={frameWidth || "auto"}
      height={frameHeight || "auto"}>
      <Box
        /* TODO:
        Text overflow?
        css style
        */
        className="PaperSheet"
        dangerouslySetInnerHTML={content} // !
        width={paperWidth || "auto"}
        height={paperHeight || "auto"}
      />
    </Box>
  );
};

class CollapsibleInput extends Component {
  constructor() {
    super();
    this.state = {
      editing: false,
    };
  };

  render() {
    return (
      <Box>
      </Box>
    );
  };
}

const CollapsibleTextInput = props => {
  const {
    content,
  } = props;
  return (
    <Input
      onChange={(e, value) => null}
      onInput={(e, value) => null}
    />
  );
};

const CollapsibleSelectInput = props => {
  const {
    content,
  } = props;
  //return (
  //);
};

const KitchenSinkCollapsible = props => {
  return (
    <Collapsible
      title="Collapsible Demo"
      buttons={(
        <Button icon="cog" />
      )}>
      <Section>
        <Box>
          Bla.
        </Box>
      </Section>
    </Collapsible>
  );
};
