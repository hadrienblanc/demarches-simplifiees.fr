import { Application } from '@hotwired/stimulus';

import { AutofocusController } from './autofocus_controller';
import { AutosaveController } from './autosave_controller';
import { AutosaveStatusController } from './autosave_status_controller';
import { GeoAreaController } from './geo_area_controller';
import { MenuButtonController } from './menu_button_controller';
import { PersistedFormController } from './persisted_form_controller';
import { ReactController } from './react_controller';
import { ScrollToController } from './scroll_to_controller';
import { SortableController } from './sortable_controller';
import { TurboEventController } from './turbo_event_controller';
import { TurboInputController } from './turbo_input_controller';
import { TurboPollController } from './turbo_poll_controller';
import { TypeDeChampEditorController } from './type_de_champ_editor_controller';
import { EllipsisableController } from './ellipsisable_controller';

const Stimulus = Application.start();
Stimulus.register('autofocus', AutofocusController);
Stimulus.register('autosave-status', AutosaveStatusController);
Stimulus.register('autosave', AutosaveController);
Stimulus.register('geo-area', GeoAreaController);
Stimulus.register('menu-button', MenuButtonController);
Stimulus.register('persisted-form', PersistedFormController);
Stimulus.register('react', ReactController);
Stimulus.register('scroll-to', ScrollToController);
Stimulus.register('sortable', SortableController);
Stimulus.register('turbo-event', TurboEventController);
Stimulus.register('turbo-input', TurboInputController);
Stimulus.register('turbo-poll', TurboPollController);
Stimulus.register('type-de-champ-editor', TypeDeChampEditorController);
