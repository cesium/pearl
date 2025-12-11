defmodule PearlWeb.Components.Ticket do
  @moduledoc false

  use PearlWeb, :component

  attr :class, :string, default: ""
  attr :attendee, :string, default: nil
  attr :ticket_type, :string, default: nil

  def ticket(assigns) do
    ~H"""
    <div class={@class}>
      <svg
        id="Layer_1"
        data-name="Layer 1"
        xmlns="http://www.w3.org/2000/svg"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        viewBox="0 0 917 350"
      >
        <defs>
          <style>
            .cls-1 {
              letter-spacing: -.01em;
            }

            .cls-2 {
              letter-spacing: -.03em;
            }

            .cls-3 {
              letter-spacing: -.01em;
            }

            .cls-4 {
              letter-spacing: -.01em;
            }

            .cls-5 {
              font-size: 21px;
            }

            .cls-5, .cls-6, .cls-7, .cls-8, .cls-9 {
              font-family: SpaceGrotesk-Regular, 'Space Grotesk';
              font-variation-settings: 'wght' 400;
            }

            .cls-5, .cls-10, .cls-11, .cls-9, .cls-12 {
              isolation: isolate;
            }

            .cls-5, .cls-10, .cls-13, .cls-14 {
              fill: #811824;
            }

            .cls-15 {
              letter-spacing: 0em;
            }

            .cls-16 {
              letter-spacing: -.03em;
            }

            .cls-6, .cls-7, .cls-8, .cls-9, .cls-17 {
              fill: #fff;
            }

            .cls-6, .cls-8 {
              font-size: 13px;
            }

            .cls-18 {
              letter-spacing: -.03em;
            }

            .cls-19 {
              letter-spacing: -.02em;
            }

            .cls-20 {
              letter-spacing: -.02em;
            }

            .cls-21 {
              letter-spacing: 0em;
            }

            .cls-22 {
              letter-spacing: -.02em;
            }

            .cls-10 {
              font-family: SpaceGrotesk-Bold, 'Space Grotesk';
              font-size: 26px;
              font-variation-settings: 'wght' 700;
              font-weight: 700;
            }

            .cls-23 {
              letter-spacing: -.01em;
            }

            .cls-24, .cls-25, .cls-17, .cls-13, .cls-14 {
              stroke-width: 0px;
            }

            .cls-7 {
              font-size: 12px;
            }

            .cls-8, .cls-12 {
              opacity: .5;
            }

            .cls-26 {
              letter-spacing: -.01em;
            }

            .cls-25 {
              fill: none;
            }

            .cls-27 {
              letter-spacing: -.01em;
            }

            .cls-28 {
              letter-spacing: 0em;
            }

            .cls-9 {
              font-size: 18px;
            }

            .cls-29 {
              letter-spacing: -.06em;
            }

            .cls-30 {
              letter-spacing: 0em;
            }

            .cls-31 {
              letter-spacing: -.02em;
            }

            .cls-32 {
              letter-spacing: 0em;
            }

            .cls-33 {
              clip-path: url(#clippath);
            }

            .cls-34 {
              letter-spacing: -.02em;
            }

            .cls-35 {
              letter-spacing: -.03em;
            }

            .cls-36 {
              letter-spacing: -.02em;
            }

            .cls-37 {
              letter-spacing: -.02em;
            }

            .cls-38 {
              letter-spacing: -.02em;
            }

            .cls-39, .cls-14 {
              opacity: .2;
            }

            .cls-40 {
              letter-spacing: -.02em;
            }

            .cls-41 {
              letter-spacing: -.01em;
            }

            .cls-42 {
              letter-spacing: 0em;
            }

            .cls-43 {
              letter-spacing: -.01em;
            }

            .cls-44 {
              letter-spacing: -.02em;
            }

            .cls-45 {
              letter-spacing: -.02em;
            }

            .cls-46 {
              letter-spacing: -.04em;
            }

            .cls-47 {
              letter-spacing: -.01em;
            }

            .cls-48 {
              letter-spacing: 0em;
            }
          </style>
          <clipPath id="clippath">
            <path
              class="cls-25"
              d="m916.5,28c-15.57,0-28.22-12.49-28.49-28h-205.03c-.27,15.51-12.91,28-28.49,28s-28.22-12.49-28.49-28H27.99c-.27,15.34-12.65,27.72-27.99,27.99v293.03c15.51.27,28,12.91,28,28.49,0,.17,0,.33-.01.5h598.03c0-.17-.01-.33-.01-.5,0-15.34,12.11-27.84,27.29-28.47-.18-.3-.29-.65-.29-1.03v-5c0-1.1.9-2,2-2s2,.9,2,2v5c0,.4-.12.78-.33,1.09,14.72,1.11,26.33,13.4,26.33,28.41,0,.17,0,.33-.01.5h205.03c0-.17-.01-.33-.01-.5,0-15.74,12.76-28.5,28.5-28.5.17,0,.33,0,.5.01V27.99c-.17,0-.33.01-.5.01Zm-259.5,277c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Zm0-15c0,1.1-.9,2-2,2s-2-.9-2-2v-5c0-1.1.9-2,2-2s2,.9,2,2v5Z"
            />
          </clipPath>
        </defs>
        <g class="cls-33">
          <rect class="cls-25" y="0" width="917" height="350" />
          <rect class="cls-17" y="0" width="917" height="350" />
          <g class="cls-11">
            <text class="cls-10" transform="translate(40 64.5)">
              <tspan x="0" y="0">enco</tspan>
              <tspan class="cls-41" x="62.17" y="0">n</tspan>
              <tspan x="77.82" y="0">t</tspan>
              <tspan class="cls-37" x="89.67" y="0">r</tspan>
              <tspan x="99.5" y="0">o n</tspan>
              <tspan class="cls-36" x="138.03" y="0">a</tspan>
              <tspan x="152.67" y="0">cional de</tspan>
            </text>
            <text class="cls-10" transform="translate(40 95.5)">
              <tspan x="0" y="0">e</tspan>
              <tspan class="cls-4" x="15" y="0">s</tspan>
              <tspan x="28.31" y="0">tuda</tspan>
              <tspan class="cls-47" x="87.8" y="0">n</tspan>
              <tspan class="cls-20" x="103.45" y="0">t</tspan>
              <tspan x="114.84" y="0">es de i</tspan>
              <tspan class="cls-47" x="195.18" y="0">n</tspan>
              <tspan class="cls-2" x="210.83" y="0">f</tspan>
              <tspan x="221.47" y="0">orm</tspan>
              <tspan class="cls-35" x="269.88" y="0">á</tspan>
              <tspan x="284.12" y="0">tica</tspan>
            </text>
          </g>
          <g class="cls-11">
            <text class="cls-5" transform="translate(40 131.77)">
              <tspan x="0" y="0">B</tspan>
              <tspan class="cls-40" x="13.88" y="0">r</tspan>
              <tspan class="cls-1" x="21.4" y="0">a</tspan>
              <tspan x="33.16" y="0">ga • 9-12 abril 2026</tspan>
            </text>
          </g>
          <g class="cls-39">
            <path
              class="cls-13"
              d="m584.36,145.34v44.51c-34.81-4.09-61.89-33.1-61.89-68.19h-16.85c0,35.09-27.07,64.11-61.89,68.19v-44.58h-16.74v204.74h16.74v-59.12c0-37.87,31.54-68.68,70.31-68.68s70.3,30.81,70.3,68.68v59.11h16.74v-204.65h-16.73Zm-70.3,60.51c-28.85,0-54.46,13.79-70.31,34.96v-34.52c31.12-2.94,57.49-21.93,70.31-48.39,12.81,26.46,39.19,45.46,70.3,48.39v34.52c-15.84-21.18-41.46-34.96-70.3-34.96Z"
            />
          </g>
          <path
            class="cls-14"
            d="m514.05,238.55c-29.54,0-53.57,23.47-53.57,52.33v59.11h16.74v-59.11c0-19.84,16.52-35.98,36.83-35.98s36.83,16.14,36.83,35.98v59.11h16.74v-59.11c0-28.86-24.03-52.33-53.57-52.33Z"
          />
          <rect class="cls-13" x="655" y="0" width="262" height="350" />
          <rect class="cls-17" x="833" y="35" width="49" height="280" />
          <rect class="cls-25" x="842" y="44" width="31.62" height="262" />
          <g class="cls-11">
            <g class="cls-12">
              <text class="cls-6" transform="translate(697.5 227) rotate(-90)">
                <tspan x="0" y="0">NOME</tspan>
              </text>
            </g>
          </g>
          <g class="cls-11">
            <g class="cls-12">
              <text class="cls-7" transform="translate(685 259.65)">
                <tspan class="cls-30" x="0" y="0">F</tspan>
                <tspan x="6.4" y="0">orum B</tspan>
                <tspan class="cls-31" x="47.02" y="0">r</tspan>
                <tspan class="cls-3" x="51.31" y="0">a</tspan>
                <tspan class="cls-42" x="58.03" y="0">ga</tspan>
              </text>
            </g>
            <g class="cls-12">
              <text class="cls-7" transform="translate(685 276.65)">
                <tspan class="cls-34" x="0" y="0">A</tspan>
                <tspan class="cls-46" x="7.31" y="0">v</tspan>
                <tspan class="cls-18" x="13.25" y="0">.</tspan>
                <tspan class="cls-42" x="15.88" y="0" xml:space="preserve">D</tspan>
                <tspan class="cls-29" x="26.92" y="0">r</tspan>
                <tspan class="cls-18" x="30.76" y="0">.</tspan>
                <tspan class="cls-42" x="33.38" y="0" xml:space="preserve">F</tspan>
                <tspan class="cls-31" x="42.95" y="0">r</tspan>
                <tspan class="cls-28" x="47.24" y="0">ancisco Pi</tspan>
                <tspan class="cls-19" x="105.77" y="0">r</tspan>
                <tspan x="110.07" y="0">es</tspan>
              </text>
            </g>
            <g class="cls-12">
              <text class="cls-7" transform="translate(685 293.65)">
                <tspan x="0" y="0">Gonçal</tspan>
                <tspan class="cls-44" x="39.71" y="0">v</tspan>
                <tspan x="45.9" y="0">es</tspan>
              </text>
            </g>
            <g class="cls-12">
              <text class="cls-7" transform="translate(685 310.65)">
                <tspan class="cls-16" x="0" y="0">4</tspan>
                <tspan class="cls-43" x="7.16" y="0">7</tspan>
                <tspan x="13.81" y="0">15-558 B</tspan>
                <tspan class="cls-22" x="64.34" y="0">r</tspan>
                <tspan class="cls-45" x="68.64" y="0">a</tspan>
                <tspan x="75.36" y="0">ga</tspan>
              </text>
            </g>
          </g>
          <g class="cls-11">
            <g class="cls-11">
              <text class="cls-8" transform="translate(759.5 227) rotate(-90)">
                <tspan x="0" y="0">ADMIS</tspan>
                <tspan class="cls-21" x="39.19" y="0">S</tspan>
                <tspan class="cls-23" x="47.11" y="0">Ã</tspan>
                <tspan class="cls-32" x="55.16" y="0">O</tspan>
              </text>
            </g>
          </g>
          <g class="cls-11">
            <text class="cls-9" transform="translate(722.23 227) rotate(-90)">
              <tspan class="cls-26" x="0" y="0">
                {if @attendee, do: @attendee, else: "Participante do ENEI"}
              </tspan>
            </text>
          </g>
          <g class="cls-11">
            <text class="cls-9" transform="translate(784.23 227) rotate(-90)">
              <tspan class="cls-26" x="0" y="0">
                {if @ticket_type, do: @ticket_type, else: "Passe Geral"}
              </tspan>
            </text>
          </g>
        </g>
        <g>
          <rect class="cls-24" x="838.75" y="302.29" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="297.57" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="290.5" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="278.71" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="271.64" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="264.57" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="250.43" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="238.64" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="233.93" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="226.86" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="219.79" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="212.71" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="200.93" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="186.79" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="182.07" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="175" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="165.57" width="37.88" height="7.07" />
          <rect class="cls-24" x="838.75" y="153.79" width="37.88" height="9.43" />
          <rect class="cls-24" x="838.75" y="146.71" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="139.64" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="127.86" width="37.88" height="7.07" />
          <rect class="cls-24" x="838.75" y="118.43" width="37.88" height="7.07" />
          <rect class="cls-24" x="838.75" y="111.36" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="101.93" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="97.21" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="92.5" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="78.36" width="37.88" height="9.43" />
          <rect class="cls-24" x="838.75" y="68.93" width="37.88" height="4.71" />
          <rect class="cls-24" x="838.75" y="54.79" width="37.88" height="7.07" />
          <rect class="cls-24" x="838.75" y="50.07" width="37.88" height="2.36" />
          <rect class="cls-24" x="838.75" y="43" width="37.88" height="4.71" />
        </g>
      </svg>
    </div>
    """
  end
end
