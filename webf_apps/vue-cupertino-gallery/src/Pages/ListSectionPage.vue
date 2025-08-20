<template>
  <div id="main">
    <!-- Standard List Section -->
    <flutter-cupertino-list-section>
      <span slotName="header">General Settings</span>

      <flutter-cupertino-list-tile show-chevron="true" @click="logClick('About')">
        <flutter-cupertino-icon slotName="leading" type="info" style="color: blue;"/>
        About
      </flutter-cupertino-list-tile>

      <flutter-cupertino-list-tile show-chevron="true" @click="logClick('Software Update')">
         <flutter-cupertino-icon slotName="leading" type="gear_alt" style="color: grey;"/>
        Software Update
        <span slotName="additionalInfo">Version 1.0.0</span>
      </flutter-cupertino-list-tile>

       <flutter-cupertino-list-tile @click="logClick('Storage')">
         <flutter-cupertino-icon slotName="leading" type="folder_open" style="color: orange;"/>
        Storage
        <span slotName="trailing">50 GB Free</span>
      </flutter-cupertino-list-tile>

      <span slotName="footer">Standard edge-to-edge list section.</span>
    </flutter-cupertino-list-section>

    <!-- Inset Grouped List Section -->
    <flutter-cupertino-list-section inset-grouped="true" style="margin-top: 20px;">
       <span slotName="header">Connectivity</span>

       <flutter-cupertino-list-tile>
          <flutter-cupertino-icon slotName="leading" type="wifi" style="color: #007aff;"/>
          Wi-Fi
          <flutter-cupertino-switch slotName="trailing" :checked="wifiEnabled" @change="wifiEnabled = $event.detail"/>
       </flutter-cupertino-list-tile>

       <flutter-cupertino-list-tile>
          <flutter-cupertino-icon slotName="leading" type="bluetooth" style="color: #007aff;"/>
          Bluetooth
          <span slotName="additionalInfo">{{ bluetoothStatus }}</span>
          <flutter-cupertino-switch slotName="trailing" :checked="bluetoothEnabled" @change="toggleBluetooth"/>
       </flutter-cupertino-list-tile>

       <flutter-cupertino-list-tile show-chevron="true" @click="logClick('VPN')">
          <flutter-cupertino-icon slotName="leading" type="lock_shield" style="color: grey;"/>
          VPN
          <span slotName="additionalInfo">Not Connected</span>
       </flutter-cupertino-list-tile>

       <span slotName="footer">Inset grouped list section with rounded corners.</span>
    </flutter-cupertino-list-section>

  </div>
</template>

<script>
export default {
  data() {
    return {
      wifiEnabled: true,
      bluetoothEnabled: false,
    }
  },
  computed: {
    bluetoothStatus() {
      return this.bluetoothEnabled ? 'On' : 'Off';
    }
  },
  methods: {
    logClick(message) {
      console.log(`ListSection Tile clicked: ${message}`);
    },
    toggleBluetooth(event) {
      this.bluetoothEnabled = event.detail;
      console.log('Bluetooth toggled:', this.bluetoothEnabled);
    }
  }
}
</script>

<style lang="scss" scoped>
#main {
  background-color: var(--background-primary);
  height: 100vh;
  width: 100vw;
  overflow-y: scroll; /* Enable scrolling */
  padding: 10px 0; /* Add some overall padding */
}

/* Styling for ListSection headers/footers/tiles is largely handled by the component */

:deep(span[slotName="header"]) {
  /* Default styles are usually fine */
}

:deep(span[slotName="footer"]) {
   /* Default styles are usually fine */
}

/* Style additionalInfo specifically if needed */
:deep(span[slotName="additionalInfo"]) {
  color: var(--font-color-secondary);
  font-size: 14px;
  margin-left: auto; /* Push it towards the trailing widget */
  padding-right: 8px; 
}

/* Style trailing text specifically if needed */
:deep(span[slotName="trailing"]) {
  color: var(--font-color-secondary);
  font-size: 14px;
}

</style>
