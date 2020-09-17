import { PortModel, DefaultLinkModel } from '@projectstorm/react-diagrams';

export class ParameterNodeModel extends PortModel {
	constructor(alignment) {
		super({
			type: 'diamond',
			name: alignment,
			alignment: alignment
		});
	}

	createLinkModel() {
		return new DefaultLinkModel();
	}
}