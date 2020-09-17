import React from 'react';

import createEngine, { 
  DefaultLinkModel, 
  DefaultNodeModel,
  DiagramModel 
} from '@projectstorm/react-diagrams';

import {
  CanvasWidget
} from '@projectstorm/react-canvas-core';

import styled from '@emotion/styled';

const engine = createEngine();

const Container =  styled.div`
    height: ${props => props.height};
    width: 100%;
    display: flex;
    > * {
			height: ${props => props.height};
			min-height: 100%;
			width: 100%;
		}
`;

export default class UDDiagram extends React.Component {

  onEventFired(e) {
     if (this.props.onSelected && e.firing && e.isSelected) 
     {
        UniversalDashboard.publish('element-event', {
            type: "clientEvent",
            eventId: this.props.onSelected,
            eventName: 'onSelected',
            eventData: e.entity.options.name
        });
     }
  }

  render() {

    var self = this;

    var nodes = this.props.nodes.map(x => {

      var nodeModel = {
        id: x.id,
        node: new DefaultNodeModel({
            name: x.name,
            color: x.color,
        }),
        inPorts: [],
        outPorts: []
      }

      nodeModel.node.setPosition(x.xOffset, x.yOffset);
      
      nodeModel.node.registerListener({ eventDidFire: self.onEventFired.bind(this) })

      if (x.inPorts) {
        nodeModel.inPorts = x.inPorts.map(y => {
            return  {
              port: nodeModel.node.addInPort(y),
              name: y
            }
        });
      }
      else {
        nodeModel.inPorts = []
      }

      if (x.outPorts) {
        nodeModel.outPorts = x.outPorts.map(y => {
            return  {
              port: nodeModel.node.addOutPort(y),
              name: y
            }
        });
      } else {
        nodeModel.outPorts = []
      }

      return nodeModel;
    });

    var links = this.props.links.map(x => {
       var outNode = nodes.find(y => y.id === x.outNode);
       if (outNode == null) return;

       var outPort = outNode.outPorts.find(y => y.name === x.outPort);
       if (outPort == null) return;

       var inNode = nodes.find(y => y.id === x.inNode);
       if (inNode == null) return;

       var inPort = inNode.inPorts.find(y => y.name === x.inPort);
       if (inPort == null) return;

       return outPort.port.link(inPort.port);
    });

    const model = new DiagramModel();

    nodes.forEach(x => model.addNode(x.node));
    links.forEach(x => model.addLink(x));

    engine.setModel(model);

    model.setLocked(this.props.locked);

    return (
      <Container height={this.props.height}>
        <CanvasWidget engine={engine}/>
      </Container>
      
    );
  }
}