import 'core-js/stable'
import 'regenerator-runtime/runtime'

import FilesApp from './components/FilesApp.vue'
import FileInfoVersions from './components/FileInfoVersions.vue'
import FileSharingSidebar from './components/FileSharingSidebar.vue'
import FileSidebarWebComponent from './components/FileSidebarWebComponent.vue'
import FileLink from './components/FileLink.vue'
import PrivateLink from './components/PrivateLink.vue'
import PublicLink from './components/PublicLinks/PublicLink.vue'
import FilesDrop from './components/PublicLinks/FilesDrop.vue'
import translationsJson from '../l10n/translations.json'

const store = require('./store')

// just a dummy function to trick gettext tools
function $gettext (msg) {
  return msg
}
const filesConfig = window.phoenixConfig.files || []
const filesSidebars = filesConfig.sidebars || []
const sidebarsFromConfig = filesSidebars.map(s => {
  return {
    app: s.tabTitle,
    component: FileSidebarWebComponent,
    title: s.tabTitle,
    propsData: {
      componentName: s.componentName,
      componentUrl: s.componentUrl
    }
  }
})

const appInfo = {
  name: $gettext('Files'),
  id: 'files',
  icon: 'folder',
  isFileEditor: false,
  extensions: [],
  fileActions: filesConfig.actions || [],
  fileSideBars: [
    {
      app: 'files-version',
      component: FileInfoVersions,
      enabled (capabilities, highlightedFile) {
        return !!capabilities.core && highlightedFile && highlightedFile.type !== 'folder'
      }
    }, {
      app: 'file-link',
      component: FileLink,
      enabled (capabilities) {
        if (capabilities.files_sharing) {
          return capabilities.files_sharing.public.enabled
        }
        return false
      }
    }, {
      app: 'files-sharing',
      component: FileSharingSidebar,
      enabled (capabilities) {
        if (capabilities.files_sharing) {
          return capabilities.files_sharing.api_enabled
        }
        return false
      },
      quickAccess: {
        icon: 'share',
        ariaLabel: $gettext('Collaborators')
      }
    }, ...sidebarsFromConfig
  ]
}
const navItems = [
  {
    name: $gettext('All files'),
    iconMaterial: appInfo.icon,
    route: {
      name: 'files-list',
      path: '/'
    }
  },
  {
    name: $gettext('Favorites'),
    iconMaterial: 'star',
    route: {
      name: 'files-favorites'
    }
  },
  {
    name: $gettext('Shared with me'),
    iconMaterial: 'share',
    route: {
      name: 'files-shared-with-me',
      path: `/${appInfo.id}/shared-with-me`
    }
  },
  {
    name: $gettext('Shared with others'),
    iconMaterial: 'share',
    route: {
      name: 'files-shared-with-others',
      path: `/${appInfo.id}/shared-with-others`
    }
  },
  {
    name: $gettext('Deleted files'),
    iconMaterial: 'delete',
    enabled (capabilities) {
      if (capabilities && capabilities.dav) {
        return capabilities.dav.trashbin === '1.0'
      }
      return false
    },
    route: {
      name: 'files-trashbin'
    }
  }
]

const routes = [
  {
    path: '',
    redirect: `/${appInfo.id}/list/`,
    components: {
      app: FilesApp
    }
  },
  {
    path: '/list/:item?',
    components: {
      app: FilesApp
    },
    name: 'files-list',
    meta: {
      hasBulkActions: true
    }
  },
  {
    path: '/favorites',
    components: {
      app: FilesApp
    },
    name: 'files-favorites',
    meta: {
      hideFilelistActions: true,
      hasBulkActions: true
    }
  },
  {
    path: '/shared-with-me',
    components: {
      app: FilesApp
    },
    name: 'files-shared-with-me',
    meta: {
      hideFilelistActions: true,
      hasBulkActions: true
    }
  },
  {
    path: '/shared-with-others',
    components: {
      app: FilesApp
    },
    name: 'files-shared-with-others',
    meta: {
      hideFilelistActions: true,
      hasBulkActions: true
    }
  },
  {
    path: '/trash-bin',
    components: {
      app: FilesApp
    },
    name: 'files-trashbin',
    meta: {
      hideFilelistActions: true,
      // FIXME: should have a generic bulk actions way as it currently handles this separately
      hasBulkActions: false
    }
  },
  {
    path: '/private-link/:fileId',
    name: 'private-link',
    components: {
      fullscreen: PrivateLink
    },
    meta: { hideHeadbar: true }
  },
  {
    path: '/public-link/:token',
    name: 'public-link',
    components: {
      fullscreen: PublicLink
    },
    meta: { auth: false, hideHeadbar: true }
  },
  {
    path: '/public-files/:item',
    name: 'public-files',
    components: {
      app: FilesApp
    },
    meta: { auth: false }
  },
  {
    path: '/files-drop/:token',
    name: 'public-files-drop',
    components: {
      app: FilesDrop
    },
    meta: { auth: false }
  }
]

const translations = translationsJson
export default define({
  appInfo,
  store,
  routes,
  navItems,
  translations
})
