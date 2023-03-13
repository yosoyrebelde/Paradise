import { useBackend } from '../backend';
import { Box, Button, Flex, NumberInput, Fragment, Section, Icon, Divider, Tooltip } from '../components';
import { Window } from '../layouts';
import { Component } from 'inferno';

export const Clipboard = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pages,
  } = data;
  // const items = ["🍰 Cake", "🍩 Donut", "🍎 Apple", "🍕 Pizza"]; //textOverflow="ellipsis"
  const items = pages.map((page, index) => (
    <Section
      key={index}
      title={page.name ? page.name : `page ${index + 1}`}
      onClick={() => act('open', { index: index })}>
      {page.preview_text ? page.preview_text.slice(0, 25) : "none"}
      <Tooltip
        content={page.description ? page.description : "Some item"}
      />
    </Section>
  ));

  return (
    <Window resizable>
      <Window.Content>
          <DraggableList
            items={items}
            onItemSwap={(index1, index2) => act('swap', {
              index1: index1,
              index2: index2,
            })}
            onItemRemove={deletedItemIdx => act('remove', { index: deletedItemIdx })}
          />
      </Window.Content>
    </Window>
  );
};

class DraggableList extends Component {
  constructor(props) {
    super(props);

    const {
      items,
      onItemRemove,
      onItemSwap,
    } = props;

    const generateDraggableElement = (item, index) => {
      return (
        <div
          className="DraggableList__Item"
          key={index}
          draggable
          onDragStart={e => this.handleDragStart(e, index)}
          onDragEnter={e => this.handleDragEnter(e, index)}
          onDragEnd={e => this.handleDragEnd(e)}
          onDragOver={e => this.handleDragOver(e)}>
          {item}
        </div>
      );
    };

    this.state = {};
    this.onItemRemove = onItemRemove;
    this.onItemSwap = onItemSwap;

    this.items = new OrderedDict();
    items.map((item, index) => {
      this.items.set(index, generateDraggableElement(item, index));
    });

    this.draggedIndex = null;
    this.draggedElem = null;
    this.mouseOutsideWindow = false;
  }

  componentDidMount() {
    this.updateState();

    // Save the binded listeners to be able to add/remove them later.
    this.handleDocumentElemDragEnter = this.dragEnterDocumentElem.bind(this);
    this.handleDocumentElemDragLeave = this.dragLeaveDocumentElem.bind(this);

    // Add the ability to catch drag from/into the window.
    document.addEventListener('dragenter', this.handleDocumentElemDragEnter);
    document.addEventListener('dragleave', this.handleDocumentElemDragLeave);
  }

  componentWillUnmount() {
    document.removeEventListener('dragenter', this.handleDocumentElemDragEnter);
    document.removeEventListener('dragleave', this.handleDocumentElemDragLeave);
  }

  updateState() {
    this.setState({ itemsToDraw: this.items.values() });
  }

  isMouseOutsideWindow(event) {
    return (
      event.clientX < 0 || event.clientX > window.outerWidth
      || event.clientY < 0 || event.clientY > window.outerHeight
    );
  }

  isDragFromThisList() {
    return !(this.draggedIndex === null);
  }

  dragLeaveDocumentElem(e) {
    if (!this.isDragFromThisList()) {
      return;
    }
    if (!this.isMouseOutsideWindow(e)) {
      return;
    }
    this.mouseOutsideWindow = true;
    this.draggedElem.classList.add("DraggableList__DeletedItem");
  }

  dragEnterDocumentElem(e) {
    if (!this.isDragFromThisList()) {
      return;
    }
    if (!this.mouseOutsideWindow) {
      return;
    }
    this.mouseOutsideWindow = false;
    this.draggedElem.classList.remove("DraggableList__DeletedItem");
  }

  handleDragStart(e, index) {
    e.dataTransfer.effectAllowed = "move";

    this.draggedIndex = index;
    this.draggedElem = e.target;
    this.mouseOutsideWindow = false;

    this.draggedElem.classList.add("DraggableList__DraggedItem");
  }

  handleDragEnter(e, index) {
    if (!this.isDragFromThisList()) {
      return;
    }

    e.preventDefault();

    // if the item is dragged over itself, ignore.
    if (index === this.draggedIndex) {
      return;
    }

    this.items.swapItems(index, this.draggedIndex);

    if (this.onItemSwap) {
      this.onItemSwap(index, this.draggedIndex);
    }

    this.updateState();
  }

  handleDragOver(e) {
    if (!this.isDragFromThisList()) {
      return;
    }

    e.preventDefault();
  }

  handleDragEnd(e) {
    if (!this.isDragFromThisList()) {
      return;
    }

    this.draggedElem.classList.remove("DraggableList__DraggedItem");

    // Delete the dragged element if it is outside the window.
    if (this.mouseOutsideWindow) {
      this.items.remove(this.draggedIndex);

      if (this.onItemRemove) {
        this.onItemRemove(this.draggedIndex);
      }

      this.updateState();
    }

    this.draggedIndex = null;
    this.draggedElem = null;
  }

  render() {
    return (
      <div ClassName="DraggableList">
        {this.state.itemsToDraw}
      </div>
    );
  }
}

class OrderedDict {
  /** Stores ordered key-value pairs. Ensures uniqueness of keys. */

  constructor() {
    this.items = [];
  }

  /** Sets the value of an item with a matching `key`.
   *  Creates a new item at the end of the dict if `key` is not found. */
  set(key, value) {
    const itemIndex = this.items.findIndex(item => item.key === key);
    if (itemIndex > -1) {
      this.items[itemIndex].value = value;
    }
    else {
      this.items.push({ key: key, value: value });
    }
  }

  /** Returns the item value or `undefined`. */
  get(key) {
    const item = this.items.find(item => item.key === key);
    if (item) {
      return item.value;
    }
  }

  /** Deletes an item with a matching `key`.
   * Raises an exeption if `key` is not found. */
  remove(key) {
    const itemIndex = this.items.findIndex(item => item.key === key);

    if (!(itemIndex > -1)) {
      throw "OrderedDict.remove() KeyError: key not found.";
    }

    this.items.splice(itemIndex, 1);
  }

  /** Swaps the two items.
   * Raises an exeption if `key` is not found. */
  swapItems(key1, key2) {
    const itemIndex1 = this.items.findIndex(item => item.key === key1);
    const itemIndex2 = this.items.findIndex(item => item.key === key2);

    if (!((itemIndex1 > -1) && (itemIndex2 > -1))) {
      throw "OrderedDict.swapItems() KeyError: key not found.";
    }

    const buffer = this.items[itemIndex1];
    this.items[itemIndex1] = this.items[itemIndex2];
    this.items[itemIndex2] = buffer;
  }

  keys() {
    return this.items.map(item => item.key);
  }

  values() {
    return this.items.map(item => item.value);
  }
}
