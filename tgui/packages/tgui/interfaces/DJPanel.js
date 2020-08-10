/**
 * @file
 * @copyright 2020
 * @author ZeWaka (https://github.com/ZeWaka)
 * @license ISC
 */

import { useBackend } from '../backend';
import { Button, Divider, NoticeBox, Section, Box, Knob, AnimatedNumber, LabeledControls } from '../components';
import { Window } from '../layouts';

export const DJPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { loadedSound } = data;
  return (
    <Window width={400} height={350} title="DJ Panel" resizable>
      <Window.Content>
        <Section>
          <Box>
            <strong>Active Soundfile: </strong>
            <Button
              icon={loadedSound ? 'file-audio' : 'upload'}
              ellipsis
              content={loadedSound ? loadedSound : "Upload"}
              onClick={() => act('set-file')}
            />
          </Box>
          <Divider />
          <KnobZone />
        </Section>
        { loadedSound ? (
          <Section>
            <Box>
              <Button
                icon="music"
                selected
                content="Play Music"
                onClick={() => act('play-music')}
              />
              <Button
                icon="volume-up"
                selected
                content="Play Sound"
                onClick={() => act('play-sound')}
              />
              <Button
                icon="record-vinyl"
                selected
                content="Play Ambience"
                onClick={() => act('play-ambience')}
              />
            </Box>
          </Section>
        ) : (
          <NothingLoaded />
        )}
        <Section>
          <Box>
            <Button
              icon="satellite-dish"
              content="Play Remote"
              onClick={() => act('play-remote')}
            />
            <Button
              icon="podcast"
              content="Play To Player"
              onClick={() => act('play-remote')}
            />
          </Box>
          <Box>
            <Button
              icon="bullhorn"
              color="yellow"
              content="Toggle DJ Announcements"
              onClick={() => act('toggle-announce')}
            />
            <Button
              icon="headphones"
              color="yellow"
              content="Toggle DJ For Player"
              onClick={() => act('play-remote')}
            />
          </Box>
          <Box>
            <Button
              icon="stop"
              color="red"
              content="Stop Last Song"
              onClick={() => act('play-remote')}
            />
            <Button
              icon="broadcast-tower"
              color="red"
              content="Stop The Radio For Everyone"
              onClick={() => act('play-remote')}
            />
          </Box>
        </Section>
        <AnnounceActive />
      </Window.Content>
    </Window>
  );
};

const NothingLoaded = () => {
  return (
    <NoticeBox danger>
      No song loaded!
    </NoticeBox>
  );
};

const AnnounceActive = (props, context) => {
  const { data } = useBackend(context);
  const { announceMode } = data;

  if (announceMode) {
    return (
      <NoticeBox info>
        Announce Mode On
      </NoticeBox>
    );
  }
};

const KnobZone = (props, context) => {
  const { act, data } = useBackend(context);
  const { loadedSound, soundVol, soundFreq } = data;

  if (loadedSound) {
    return (
      <Box>
        <LabeledControls>
          <LabeledControls.Item label="Volume">
            <AnimatedNumber
              value={soundVol}
            />
          </LabeledControls.Item>
          <LabeledControls.Item>
            <Knob
              minValue={0}
              maxValue={100}
              ranges={{
                bad: [90, 100],
                average: [70, 89],
              }}
              value={soundVol}
              onDrag={(e, value) => act('set-volume', {
                volume: value,
              })}
            />
            <Button
              icon="sync-alt"
              top="0.3em"
              content="Reset"
              onClick={() => act('set-volume', {
                volume: "reset",
              })}
            />
          </LabeledControls.Item>
          <LabeledControls.Item label="Frequency">
            <AnimatedNumber
              value={soundFreq + '00%'}
            />
          </LabeledControls.Item>
          <LabeledControls.Item>
            <Knob
              minValue={-100}
              maxValue={100}
              ranges={{
                bad: [-100, -50],
                red: [50, 100],
              }}
              value={soundFreq}
              unit="%"
              onDrag={(e, value) => act('set-freq', {
                frequency: value,
              })}
            />
            <Button
              icon="sync-alt"
              top="0.3em"
              content="Reset"
              onClick={() => act('set-freq', {
                frequency: "reset",
              })}
            />
          </LabeledControls.Item>
        </LabeledControls>
      </Box>
    );
  }
};
