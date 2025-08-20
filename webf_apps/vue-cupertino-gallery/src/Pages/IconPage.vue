<template>
    <div id="main">
      <webf-listview id="list">
        <div class="component-section">
          <div class="section-title">Icon</div>
          <div class="component-block">
            <!-- Basic Icons -->
            <div class="component-item">
              <div class="item-label">Basic Icons</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="home" />
                <flutter-cupertino-icon type="person" />
                <flutter-cupertino-icon type="settings" />
                <flutter-cupertino-icon type="search" />
              </div>
            </div>
  
            <!-- Filled Icons -->
            <div class="component-item">
              <div class="item-label">Filled Icons</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="location_fill" />
                <flutter-cupertino-icon type="person_fill" />
                <flutter-cupertino-icon type="star_fill" />
                <flutter-cupertino-icon type="heart_fill" />
              </div>
            </div>
  
            <!-- Different Sizes -->
            <div class="component-item">
              <div class="item-label">Different Sizes</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="star" style="font-size: 16px;" />
                <flutter-cupertino-icon type="star" style="font-size: 24px;" />
                <flutter-cupertino-icon type="star" style="font-size: 32px;" />
                <flutter-cupertino-icon type="star" style="font-size: 48px;" />
              </div>
            </div>
  
            <!-- Different Colors -->
            <div class="component-item">
              <div class="item-label">Different Colors</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="heart_fill" style="color: #ff6b81;" />
                <flutter-cupertino-icon type="star_fill" style="color: #ffd700;" />
                <flutter-cupertino-icon type="check_mark_circled" style="color: #2ecc71;" />
                <flutter-cupertino-icon type="info_circle" style="color: #3498db;" />
              </div>
            </div>
  
            <!-- Action Icons -->
            <div class="component-item">
              <div class="item-label">Action Icons</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="plus" />
                <flutter-cupertino-icon type="minus" />
                <flutter-cupertino-icon type="delete" />
                <flutter-cupertino-icon type="trash" />
              </div>
            </div>
  
            <!-- Navigation Icons -->
            <div class="component-item">
              <div class="item-label">Navigation Icons</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="back" />
                <flutter-cupertino-icon type="forward" />
                <flutter-cupertino-icon type="arrow_left" />
                <flutter-cupertino-icon type="arrow_right" />
              </div>
            </div>
  
            <!-- Status Icons -->
            <div class="component-item">
              <div class="item-label">Status Icons</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="check_mark" />
                <flutter-cupertino-icon type="xmark" />
                <flutter-cupertino-icon type="question" />
              </div>
            </div>
  
            <!-- Media Icons -->
            <div class="component-item">
              <div class="item-label">Media Icons</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="play_fill" />
                <flutter-cupertino-icon type="pause_fill" />
                <flutter-cupertino-icon type="stop_fill" />
                <flutter-cupertino-icon type="forward_fill" />
              </div>
            </div>
  
            <!-- System Icons -->
            <div class="component-item">
              <div class="item-label">System Icons</div>
              <div class="icon-row">
                <flutter-cupertino-icon type="wifi" />
                <flutter-cupertino-icon type="wifi_exclamationmark" />
                <flutter-cupertino-icon type="wifi_slash" />
                <flutter-cupertino-icon type="battery_100" />
              </div>
            </div>
          </div>
        </div>
      </webf-listview>
    </div>
  </template>
  
  <style lang="scss" scoped>
  #list {
    padding: 10px 0;
    height: 100vh;
    width: 100vw;
    background-color: var(--background-primary);
  }
  
  .component-section {
    padding: 16px;
    margin-bottom: 8px;
  
    .section-title {
      font-size: 20px;
      font-weight: 600;
      color: var(--font-color-primary);
      margin-bottom: 16px;
    }
  
    .component-block {
      background-color: var(--background-secondary);
      border-radius: 12px;
      padding: 16px;
  
      .component-item {
        margin-bottom: 24px;
  
        &:last-child {
          margin-bottom: 0;
        }
  
        .item-label {
          font-size: 14px;
          color: var(--font-color-secondary);
          margin-bottom: 12px;
        }
      }
    }
  }
  
  .icon-row {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
  
    :deep(flutter-cupertino-icon) {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 40px;
      height: 40px;
      background-color: var(--background-primary);
      border-radius: 8px;
      margin-right: 24px;
      margin-bottom: 24px;

      &:last-child {
        margin-right: 0;
      }
    }
  }
  </style>