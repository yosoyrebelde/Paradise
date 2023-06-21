import { useBackend } from '../backend';
import { Box, Button, Flex, NumberInput, Fragment, Section, Icon, Divider, Collapsible } from '../components';
import { Window } from '../layouts';
import { Component } from 'inferno';

export const PaperSheet = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    content,
  } = data;

  return (
    <Window resizable>
      <Window.Content>
        <Box onwheel={e => act('MSG', {msg: "WHEEL"})}>
          Yoyoyoyo
        </Box>
      </Window.Content>
    </Window>
  );
};

/*
  return (
    <Window resizable>
      <Window.Content>
        <PaperContent
          content={content}
        />
      </Window.Content>
    </Window>
  );
};
*/
const PaperContent = props => {
  const {
    content,
    ...rest
  } = props;
  return (
  /* TODO:
  Text overflow?
  css style
  */
    <Box
      className="PaperSheet"
      overflow="auto"
      dangerouslySetInnerHTML={{__html: content}} // !
      {...rest}>
    </Box>

  );
};

const PaperInputField = props => {
  const {
  } = props;
  return (
    <Box>
    </Box>
  );
};




class CollapsibleInput extends Component {
  constructor(props) {
    super(props);
    const {
      open,
      collapsibleContent,
      collapsibleY,
      minX,
      maxX,
    } = props;

    this.collapsibleContent = collapsibleContent

    this.state = {
      open: open || false,
    };
  }

  toggle() {
    this.setState({ open: !open })
  }

  render() {
    return (
      <span>
        <span className="CollapsibleInput__clickable">

        </span>
        <div className="CollapsibleInput__collapsible">
          <div>
            Arrow
          </div>
          <div>
            {this.collapsibleContent}
          </div>
        </div>
      </span>
    );
  }
}


/*

const PaperSheetFrame = props => {
  const {
    content,
    paperWidth,
    paperHeight,
    ...rest
  } = props;
  return (
    <Box
      {...rest}>
      <Box
        width="auto"
        height="auto"
        overflow="auto">
        <BoxTODO:
          Text overflow?
          css style
          className="PaperSheet"
          width={paperWidth || "auto"}
          height={paperHeight || "auto"}
          dangerouslySetInnerHTML={{__html: content}} // !
        />
      </Box>
    </Box>
  );
};

const MyInput = props => {
  return (
    <span contenteditable="true">
      Bla.
    </span>
  );
};

class CollapsibleInput extends Component {
  constructor(props) {
    super(props);
    const {
      open,
      button,
    } = props;
    this.state = {
      open: open || false,
    };
  };

  render() {
    return (
      <Box><Button></Button>
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
*/
